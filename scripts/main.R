#####package set up
###https://github.com/agoldst/dfrtopics/tree/b547081f5159d38e24309c439192f48bfd0a2357
package_list <- c("mallet", "tidyverse", "ggdendro", "tm")

install_packages <- function(packages) {
  for (p in packages) {
    if (p %in% rownames(installed.packages())) {
      library(p, character.only = TRUE)
    } else {
      install.packages(p)
      library(p, character.only = TRUE)
    }
  }
}

install_packages(package_list)
lapply(package_list, require, character.only=TRUE)

##### Mallet setup

###variables
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


alpha_iterations <- 20
alpha_sum <- 1
beta <- .01

burn_in <- 10
iterations <- 200
topics <- 73 #found using CaoJuan 

seed <- 359 #for reproducability (359 was chosen arbitrarily, it's JP Crawford's wOBA for the 2023 season)

stoplist_file <- file.path("top_words.txt") #calculated using tf-idf
stoplist <- readLines(stoplist_file)


#RAM allocation - 24 gigs
options(java.parameters = "-Xmx6g")

###read data into R

appellate_files <- list.files(
  path = "data/input/appellate", 
  pattern = "\\.txt$", 
  full.names = TRUE)
# district_files <- list.files(
#   path = "data/input/district", 
#   pattern = "\\.txt$", 
#   full.names = TRUE)

# file_list <- c(appellate_files, district_files)
file_list <- appellate_files
corpus <- Corpus(URISource(file_list))
###text cleaning

corpus <- tm_map(corpus, content_transformer(tolower)) #conerts all text to lowercase
corpus <- tm_map(corpus, removePunctuation) #removes punctuation
corpus <- tm_map(corpus, removeNumbers) #removes numbers
corpus <- tm_map(corpus, stripWhitespace) #removes blank space 
corpus <- tm_map(corpus, removeWords, stopwords) #removes stopwords

##### running mallet

##create topic model
topic_model <- MalletLDA(
  num.topics = topics, 
  alpha.sum = alpha_sum, 
  beta = beta)


##hyperoptimization 
topic_model$setAlphaOptimization(alpha_iterations, burn_in)

##set seed
# topic_model$setRandomSeed(seed)

##load docs
topic_model$loadDocuments(corpus)

##train model
topic_model$train(iterations)

##save model
state_file <- file.path(tempdir(), "/data/output/temp_mallet_state.gz")
save.mallet.state(topic.model = topic_model, state.file = state_file)




#####analysis
###gather basic results for further processing
# adds smoothing so no probability = 0; smoothing amount = alpha_sum
#NOTE - Java indexes from 0, so the 1st model is topic 0, 2nd is topic 1, etc.

doc_topics <- mallet.doc.topics(topic.model, smoothed = TRUE, normalized = TRUE) #returns matrix w 1 row per document and 1 column per topic
topic_words <- mallet.topic.words(topic.model, smoothed = TRUE, normalized = TRUE) #returns matrix w 1 row per topic and 1 column per word 

topic_labels <- mallet.topic.labels(topic_model) #returns vector for each topic w the most probable words in that topic

top_words <- mallet.top.words(topic.model, word.weights = topic.words[2,], num.top.words = 5) #returns df w 2 columns, 1 containing probable words as vector and the other containing weight assigned. 

###perplexity
##function to calculate perplexity
calculate_perplexity <- function(doc.word.counts, doc.topics, topic.words) {
  # Normalize word counts to get probabilities
  doc.word.probs <- t(apply(doc.word.counts, 1, function(row) row/sum(row)))
  
  # Convert topic.words matrix to list format
  topics_word_distributions <- split(data.frame(topic.words), seq(nrow(topic.words)))
  
  # Calculate the log probability of each document
  log_probs <- sapply(1:nrow(doc.word.counts), function(d) {
    wd_probs <- doc.word.probs[d,]
    theta_d <- doc.topics[d,]
    log_prob_d <- sum(sapply(1:ncol(doc.word.counts), function(w) {
      p_wd <- sum(theta_d * sapply(1:nrow(topic.words), function(k) {
        topics_word_distributions[[k]][, w]
      }))
      log(p_wd)
    }))
    return(log_prob_d)
  })
  
  # Calculate the total number of words across all documents
  N <- sum(doc.word.counts)
  
  # Calculate the perplexity
  perplexity <- exp(-sum(log_probs) / N)
  
  return(perplexity)
}

##function to find word count per document
compute_doc_word_counts <- function(documents, vocabulary) {
  # Create a matrix to store word counts
  doc.word.counts <- matrix(0, nrow = length(documents), ncol = length(vocabulary), 
                            dimnames = list(NULL, vocabulary))

  # Fill the matrix with word counts
  for (i in 1:length(documents)) {
    doc.words <- documents[[i]]
    for (word in unique(doc.words)) {
      if (word %in% vocabulary) {
        doc.word.counts[i, word] <- sum(doc.words == word)
      }
    }
  }
  
  return(doc.word.counts)
}

##run functions
word_prob <- compute_doc_word_counts(corpus, topic_words)
topic_perplexity <- calculate_perplexity(word_prob, doc_topics, topic_words)


###dendrogram
#@balance = value between 0 and 1 where 0 = only document similarity & 1 = only word-level similarity

plot(mallet.topic.hclust(doc_topics, topic_words, balance = 0.3), labels=topic_labels)


#####oh baby it's probability graph time

###import data and manipulation
##import meta data & tidy
meta_data <- tidy(read.csv(file = "data/court_opinions_data.csv", header = TRUE))

##tidy doc_topics
doc_topics <- tidy(doc_topics)

##merge
meta_w_probs <- merge()
#export
write.table(meta_w_probs, file = "data/output/meta_w_probs.csv")
##time graph
for t in time

##level graph
ggplot2

##court graph