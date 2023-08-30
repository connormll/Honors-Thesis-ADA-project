stopwords <- mallet_stoplist_file_path("en")
directory <- "case_text"
files_in_directory <- list.files(directory, full.names = TRUE)

txt_file_content <- character(length(files_in_directory))

for (i in seq_along(files_in_directory)) {
  txt_file_content[i] <- paste(readLines(files_in_directory[i]), collapse = "\n")
}

str(txt_file_content)

cases.instances <-
  mallet.import(id.array = row.names(txt_file_content),
                text.array = files_in_directory,
                stoplist = stopwords,
                token.regexp = "\\p{L}[\\p{L}\\p{P}]+\\p{L}"
                  )
