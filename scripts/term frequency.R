library(dplyr)
library(tidytext)

cases <- "case_text/appellate"
directory_files <- list.files(cases, full.names = TRUE)

cases_frame <- data.frame(
  title = directory_files,
  text = for (i in seq_along(directory_files)) {
    txt_file_content[i] <- paste(readLines(directory_files[i]), collapse = "\n")
  }
)

print(cases_frame)

# case_words <- case_documents() %>%
#   unnest_tokens(word, text) %>%
#   count(word)
