library(ggplot2)
library(tidyverse)
library(readxl)
library(ggstatsplot)
library(lm)
library(hexbin)

#read in data
data_sorted <- read_excel("/data/excel.xlsx", sheet = "Sorted")

#gather names for for loop
column_names <- names(data_sorted)[-1]

mass_greaph <- ggplot(
  data = data_sorted,
  aes(
    x = Date,
    y = ,
  )
) +
  stat_binhex() +
  scale_fill_gradiant(
    low = "lightblue",
    high = "red",
    limits = c(0,)
  )

for (col_name in column_names) {
  p <- ggplot(
    data = data_sorted,
    aes(
      x = "Date",
      y = col_name
    )
  )
  p +
    geom_point(colour = "grey60") +
    stat_smoth(method = lm, colour = "black")
}