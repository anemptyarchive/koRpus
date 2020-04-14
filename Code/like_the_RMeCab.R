
# koRpusの出力ををRMeCabのように ---------------------------------------------------

## 利用パッケージ
# TreeTagger
library(koRpus)
library(koRpus.lang.en)
# MeCab
library(RMeCab)
# その他処理
library(dplyr)
library(readr)


#TreeTaggerを利用するための設定
set.kRp.env(TT.cmd = "C:\\TreeTagger\\bin\\tag-english.bat", lang = "en")

# フォルダ名を指定
folder_name <- "text_data"

# ファイル名を指定
file_name <- "wonderful_world.txt"

# TreeTaggerによる英文形態素解析
res_tt <- taggedText(treetag(paste(folder_name, file_name, sep = "/")))
?taggedText
# 必要なデータを抽出
tt_data <- res_tt %>% 
  select(lemma, wclass, tag) %>% # 列を取り出す
  count(lemma, wclass, tag) %>% # 頻度を集計
  rename(TERM = lemma, !!file_name := n) %>% # 列名をRMeCab使用に変更POS1 = wclass, POS2 = tag, 
  arrange(TERM) # 昇順に並べ替え


# 変換 ----------------------------------------------------------------------

# 対応表を読み込む
pos_data <- read_csv("table_data/pos_data.csv")

# 品詞大分類の対応表
wclass_data <- pos_data %>% 
  select(wclass, POS1) %>% 
  filter(!is.na(wclass)) %>% 
  distinct(wclass, .keep_all = TRUE)

# 品詞細分類の対応表
tag_data <- pos_data %>% 
  select(tag, POS2) %>% 
  filter(!is.na(tag))

# 品詞情報を付与
tt_data2 <- tt_data %>% 
  left_join(wclass_data, by = "wclass") %>% 
  left_join(tag_data, by = "tag")

# RMeCab風に変換
tt_data3 <- tt_data2 %>% 
  select(TERM, POS1, POS2, all_of(file_name))


