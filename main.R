#https://rdrr.io/cran/mallet/f/vignettes/mallet.Rmd

#RAM allocation
options(java.parameters = "-Xmx6g")

#basic Mallet setup
library(mallet)

alpha_iterations <- 20
burn_in <- 50
iterations <- 200

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

topic.model <- MalletLDA(num.topics = 10, alpha.sum = 1, beta = 0.1)
topic.model$loadDocuments(cases.instances)

vocabulary <- topic.model$getVocabulary()
head(vocabulary)

word_freq <- mallet.word.freqs(topic.model)
head(word_freq)

topic.model$setAlphaOptimization(alpha_iterations,burn_in)

#basic analysis - adds smoothing so no probability = 0
#NOTE - Java indexes from 0, so the 1st model is topic 0, 2nd is topic 1, etc.

doc.topics <- mallet.doc.topics(topic.model, smoothed = TRUE, normalized = TRUE)
topic.words <- mallet.topic.words(topic.model, smoothed = TRUE, normalized = TRUE)

mallet.top.words(topic.model, word.weights = topic.words[2,], num.top.words = 5)

#ggplot graphing
library(ggplot2)
ggplot(best.model.logLik.df, aes(x=topics, y=LL)) +
  xlab("Number of topics") + ylab("Log likelihood of the model") +
  geom_line() +
  theme_bw()