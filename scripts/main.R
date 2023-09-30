#https://rdrr.io/cran/mallet/f/vignettes/mallet.Rmd
#https://www.tidytextmining.com/

#RAM allocation
options(java.parameters = "-Xmx6g")

#basic Mallet setup

#@alpha_iterations : controls the mixture of topics. 
#alpha < 1 = distribution nearer to the topics, less mixture of topics
#alpha => 1 = distribution is mixed together, more representative of all topics
#should generally be alpha = 1/# of topics
#@beta : determines how many words are associated w each topic. 
#lower value = fewer words
#tl;dr
#lower beta -> sharper topics, fewer words
#lower alpha -> sharper categorization

#@burn_in : number of first iterations discarded

#@iterations : # of times sampling is ran to train model

#@freq_words : the maximum number of documents a phrase can be in without being 
#pruned. A freq_words of 10, for instance, would prune a word/phrase if it was 
#10 or more documents. 
#@rare_words : opposite of freq_words, min # of documents a word/phrase needs to
#appear in. 
#@min_IDF & @max_idf = inverse document frequency. Measure of importance of a 
#word/phrase. finds log of rare/freq words (don't worry about it too much)

library(mallet)
library(tidyverse)

alpha_iterations <- 20
alpha_sum <- 1
beta <- .01

burn_in <- 10
iterations <- 200
freq_words <- 
rare_words <-
topics <- 10

min_IDF <- log(rare_words)
max_IDF <- log(freq_words)


#reads data into R

stopwords <- mallet_stoplist_file_path("en")
directory <- "case_text"
files_in_directory <- list.files(directory, full.names = TRUE)

txt_file_content <- character(length(files_in_directory))

for (i in seq_along(files_in_directory)) {
  txt_file_content[i] <- paste(readLines(files_in_directory[i]), collapse = "\n")
}

str(txt_file_content)

#text cleaner

cases.instances <-
  mallet.import(id.array = row.names(txt_file_content),
                text.array = files_in_directory,
                stoplist = stopwords,
                token.regexp = "\\p{L}[\\p{L}\\p{P}]+\\p{L}"
                  )

#topic trainer

topic.model <- MalletLDA(num.topics = topics, alpha.sum = alpha_sum, beta = 0.1)
topic.model$loadDocuments(cases.instances)

vocabulary <- topic.model$getVocabulary()
head(vocabulary)

word_freq <- mallet.word.freqs(topic.model)
head(word_freq)

topic.model$setAlphaOptimization(alpha_iterations,burn_in)

#basic analysis - adds smoothing so no probability = 0
#smoothing amount = alpha_sum
#NOTE - Java indexes from 0, so the 1st model is topic 0, 2nd is topic 1, etc.

doc.topics <- mallet.doc.topics(topic.model, smoothed = TRUE, normalized = TRUE)
topic.words <- mallet.topic.words(topic.model, smoothed = TRUE, normalized = TRUE)

mallet.top.words(topic.model, word.weights = topic.words[2,], num.top.words = 5)

###topic evaluators

#coherence
