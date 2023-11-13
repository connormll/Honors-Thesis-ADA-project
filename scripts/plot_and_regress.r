library(ggplot2)
library(tidyverse)
library(readxl)


#read in data
data_sorted <- read_excel("~/Github/Honors-Thesis-ADA-project/data/excel.xlsx", 
                          sheet = "Sorted", col_types = c("numeric", 
                                                          "text", "date", "text", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric", 
                                                          "numeric", "numeric", "numeric"))

#gather names for for loop
column_names <- names(data_sorted)[5:77]
date_column <- data_sorted[[3]]

for (col_name in column_names) {
  p <- ggplot(data = data_sorted,aes_string(x = names(data_sorted)[3], y = col_name)) +
    geom_point() +
    theme_bw()+
    geom_smooth(method=lm, color="red", fill="#69b3a2", se=TRUE) +
    ylim(0,1)
    labs(title = paste("Probability plot for topic #", col_name), 
         x = "Time",
         y = "Probability")
  ggsave(
    filename = paste0("~/Github/Honors-Thesis-ADA-project//data/output/ggplots/plot_", col_name, ".png"), plot = p)
}
