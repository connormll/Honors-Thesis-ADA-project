#####package set up
package_list <- c("mallet", "ggplot2", "ggdendro", "tm")

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

#RAM allocation - 16 gigs
options(java.parameters = "-Xmx16g")

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

stopwords <- "top_words.txt" #calculated using tf-idf

###read data into R

appellate_files <- list.files(
  path = "data/appellate", 
  pattern = "\\.txt$", 
  full.names = TRUE)
district_files <- list.files(
  path = "data/district", 
  pattern = "\\.txt$", 
  full.names = TRUE)

file_list <- c(appellate_files, district_files)

corpus <- Corpus(URISource(file_list))
###text cleaning

corpus <- tm_map(corpus, content_transformer(tolower)) #conerts all text to lowercase
corpus <- tm_map(corpus, removePunctuation) #removes punctuation
corpus <- tm_map(corpus, removeNumbers) #removes numbers
corpus <- tm_map(corpus, stripWhitespace) #removes blank space 
corpus <- tm_map(corpus, removeWords, stopwords) #removes stopwords

##### running mallet

#create topic model
topic_model <- MalletLDA(
  num.topics = topics, 
  alpha.sum = alpha_sum, 
  beta = beta)
topic_model$loadDocuments(cases_instances)

#train model
topic_model$train(iterations)

#####analysis

###gather basic results for further processing
# adds smoothing so no probability = 0smoothing amount = alpha_sum
#NOTE - Java indexes from 0, so the 1st model is topic 0, 2nd is topic 1, etc.
doc_topics <- mallet.doc.topics(topic.model, smoothed = TRUE, normalized = TRUE) #returns matrix w 1 row per document and 1 column per topic
topic_words <- mallet.topic.words(topic.model, smoothed = TRUE, normalized = TRUE) #returns matrix w 1 row per topic and 1 column per word 

topic_labels <- mallet.topic.labels(topic_model) #returns vector for each topic w the most probable words in that topic

top_words <- mallet.top.words(topic.model, word.weights = topic.words[2,], num.top.words = 5) #returns df w 2 columns, 1 containing probable words as vector and the other containing weight assigned. 

##dendrogram
#balance = value between 0 and 1 where 0 = only document similarity & 1 = only word-level similarity
#0.3 is default

plot(mallet.topic.hclust(doc_topics, topic_words, balance = 0.3), labels=topic_labels)


