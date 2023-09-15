library(tidyverse)

#gather all files
app_files <- list.files(
  path = "case_text/district", 
  pattern = "\\.txt$",
  full.names = TRUE
)

district_files <- list.files(
  path = "case_text/district",
  pattern = "\\.txt$",
  full.names = TRUE
)

all_files <- c(app_files, district_files)

#function to read/preprocess
process_txt <- function(file) {
  text <- tolower(readLines(file, warn = FALSE))
  words <- unlist(strsplit(text,"\\W"))
  words <- words[words != ""]
  return(words)
}

#read all files
all_words <- unlist(lapply(all_files, process_txt))

#count/log freq
word_freq <- table(all_words)


#term-doc freq
doc_freq <- lapply(all_files, function(file){
  uniq_words <- unique(process_txt(file))
  return(unique_words)
}) %>% unlist() %>% table()

#combine word and doc freq

results <- data.frame(
  Word = names(word_freq),
  Frequency = as.interger(word.freq),
  DocFreq = as.interger(doc_freq[names(word_freq)])
)

#write to csv
write.csv(results, "word_frequencies_dis.csv", row.names = TRUE)