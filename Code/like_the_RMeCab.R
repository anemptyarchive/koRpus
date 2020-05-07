
# koRpusの出力ををRMeCab仕様に ---------------------------------------------------

# パッケージの読み込み ----------------------------------------------------------------------

## 利用パッケージ
# TreeTagger
library(koRpus)
library(koRpus.lang.en)

# MeCab
library(RMeCab)

# その他処理
library(dplyr)
library(readr)

# TreeTaggerを利用するための設定
set.kRp.env(TT.cmd = "C:\\TreeTagger\\bin\\tag-english.bat", lang = "en")


# 英語形態素解析 -----------------------------------------------------------------

# フォルダ名を指定
folder_name <- "text_data"

# ファイル名を指定
file_name <- "wonderful_world.txt"

# TreeTaggerによる英文形態素解析
res_tt <- taggedText(treetag(paste(folder_name, file_name, sep = "/"))) %>% 
  as_tibble()

# 必要なデータを抽出
tt_data <- res_tt %>% 
  select(lemma, wclass, tag) %>% # 必要な列を取り出す
  count(lemma, wclass, tag) %>% # 単語の出現頻度を集計
  rename(TERM = lemma, !!file_name := n) %>% # RMeCab仕様に列名を変更
  arrange(TERM) # 昇順に並べ替え


# 品詞情報の対応表 ----------------------------------------------------------------------

# 対応表を読み込む
pos_data <- read_csv(
  "table_data/pos_data.csv", 
  col_types = cols(
    tag = col_factor(), 
    wclass = col_factor()
  )
)

# 品詞大分類の対応表
wclass_data <- pos_data %>% 
  select(wclass, POS1) %>% # 品詞(大分類)の列を取り出す
  filter(!is.na(wclass)) %>% # NAの行を除外
  distinct(wclass, .keep_all = TRUE) # 重複を除外

# 品詞細分類の対応表
tag_data <- pos_data %>% 
  select(tag, POS2) %>% # 品詞(細分類)の列を取り出す
  filter(!is.na(tag)) # NAの行を除外


# docDF()仕様に変換 ------------------------------------------------------------

# RMeCab風に変換
mc_data <- tt_data %>% 
  left_join(wclass_data, by = "wclass") %>% # 品詞(大分類)情報を結合
  left_join(tag_data, by = "tag") %>% # 品詞(細分類)情報を結合
  select(TERM, POS1, POS2, all_of(file_name)) # 必要な列を取り出す


# (確認用)MeCabによる形態素解析
res_mc <- docDF(paste(folder_name, file_name, sep = "/"), type = 1) %>% 
  as_tibble()


