library(tidyverse)
library(widyr)


#gather .txt files
appellate_files <- list.files(
  path = "case_text/appellate", 
  pattern = "\\.txt$", 
  full.names = TRUE)
district_files <- list.files(
  path = "case_text/district", 
  pattern = "\\.txt$", 
  full.names = TRUE)

all_files <- c(appellate_files, district_files)

#read and preprocess text
process_text <- function(file) {
  text <- tolower(readLines(file, warn = FALSE))
  words <- unlist(strsplit(text, "\\W"))
  words <- words[words !=""]
  return(words)
}

#read and process files
all_words <- unlist(lapply(all_files, process_text))

countem <- table(all_words)

#term-doc freq
doc_freq <- lapply(all_files, function(file){
  unique_words <- unique(process_text(file))
  return(unique_words)
}) %>% unlist() %>% table()

results <- data.frame (
  Term = names(countem),
  Frequency = as.integer(countem),
  DocFreq = as.integer(doc_freq[names(countem)])
)

#compute co-occurrence Pointwise Mutual Information for a given word
#the math is over my head, don't ask me how this works. See the following:
#* David Newman, Jey Han Lau, Karl Grieser, and Timothy Baldwin. 
#   “Automatic Evaluation of Topic Coherence,” 100–108. 
#   Los Angeles: Association for Computational Linguistics, 2010. 
#   https://aclanthology.org/N10-1012.pdf.
#* Lee, Jung-Been, Taek Lee, and Hoh Peter In. 
#   “Automatic Stop Word Generation for Mining Software Artifact Using 
#   Topic Model with Pointwise Mutual Information.” IEICE Transactions on 
#   Information and Systems E102.D, no. 9 (2019): 1761–72. 
#   https://doi.org/10.1587/transinf.2018EDP7390.

compute_PMI <- function(target_word, cooc_matrix, word_freq, total_words) {
  #calculate probabilities
  Px <- word_freq[target_word] / total_words
  Py <- word_freq / total_words
  Pxy <- cooc_matrix[target_word, ] / sum(cooc_matrix[target_word, ])
  
  #compute PMI, avoiding div by 0 and log of 0
  PMI <- log2((Pxy + 1e-10) / (Px * Py + 1e-10))
  
  return(PMI)
}

#create co-occurance matrix
word_pairs <- pairwise_count(
  data_frame(word=all_words), 
  word, 
  word, 
  sort = TRUE)

#convert to matrix for easier computation
cooc_matrix <- spread(word_pairs, item2, n, fill = 0)
rownames(cooc_matrix) <- cooc_matrix$item1
cooc_matrix$item1 <- NULL



#write to CSV
write.csv(results, "word_freq.csv", row.names = TRUE)
