
# koRpusの出力ををRMeCabのように ---------------------------------------------------

## 利用パッケージ
# TreeTagger
library(koRpus)
library(koRpus.lang.en)
# MeCab
library(RMeCab)
# その他処理
library(dplyr)

#TreeTaggerを利用するための設定
set.kRp.env(TT.cmd = "C:\\TreeTagger\\bin\\tag-english.bat", lang = "en")

# フォルダ名を指定
folder_name <- "text_data"

# ファイル名を指定
file_name <- "wonderful_world.txt"

# TreeTaggerによる英文形態素解析
res_tt <- taggedText(treetag(paste(folder_name, file_name, sep = "/")))

# 必要なデータを抽出
tt_data <- res_tt %>% 
  select(lemma, wclass, tag) %>% 
  count(lemma, wclass, tag) %>% 
  rename(TERM = lemma, POS1 = wclass, POS2 = tag, !!file_name := n) %>% 
  arrange(TERM)

