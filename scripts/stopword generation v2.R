library(dplyr)
library(tidyr)
library(tokenizers)

#gather .txt files
appellate_files <- list.files(
  path = "case_text/appellate", 
  pattern = "\\.txt$", 
  full.names = TRUE)
district_files <- list.files(
  path = "case_text/district", 
  pattern = "\\.txt$", 
  full.names = TRUE)

corpus <- c(appellate_files, district_files)

#tokenize corpus
tokenized_corpus <- unlist(tokenize_words(corpus))

#term frequency
tf <- table(tokenized_corpus)

#doc frequency
df <- sapply(names(tf), function(word){
  sum(grepl(pattern = word, x = corpus, fixed = TRUE))
})

#co-occurrence
co_oc <- matrix(0, nrow=length(tf), ncol = length(tf))
rownames(co_oc) <- names(tf)
colnames(co_oc) <- names(tf)

for(i in 1:length(corpus)) {
  doc_terms <- unique(tokenize_words(corpus[i]))
  for(j in 1:length(doc_terms)) {
    for(k in 1:length(doc_terms)) {
      if(j != k) {
        co_oc[doc_terms[j], doc_terms[k]] <- co_oc[doc_terms[j], doc_terms[k]] + 1
      }
    }
  }
}

#convert matrix to data frame for easier manipulation
co_oc_df <- as.data.frame(as.table(co_oc))

#expand df
co_oc_exp <- co_oc_df %>%
  seperate(Var1, into = c("word_i", "word_j"), sep = "-", remove = FALSE) %>%
  mutate(tf)