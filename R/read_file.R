#' Read file switcher
#'
#' @param mimetype string
#' @param originalname string
#' @param path string
#'
#' @return dataframe/matrix/sparse matrix
#'
#' @references https://rviews.rstudio.com/2019/08/13/plumber-logging/
read_deepmaps <-
  function(mimetype = "application/vnd.ms-excel",
           # originalname = 'pbmc_granulocyte_sorted_3k_filtered_feature_bc_matrix.h5',
           path = "c57e41d078ce9810717de392b4451605") {
    if (!file.exists("/data")) {
      path_prefix <- "C:/Users/flyku/Documents/deepmaps-data/"
    } else {
      path_prefix <- "/data/"
    }

    absolute_path <- paste0(path_prefix, path)
    #absolute_path <- "C:/Users/flyku/Documents/deepmaps-data/b16af116a67fc89ec0991170f99b7503"
    result <-
      switch(mimetype,
        "application/vnd.ms-excel" = read_deepmaps_text(absolute_path),
        "application/octet-stream" = read_deepmaps_h5(absolute_path)
      )
    return(result)
  }

#' Read csv,tsv,txt format
#'
#' @param path string
#'
#' @return dataframe/matrix/sparse matrix
#'
#' @references https://rviews.rstudio.com/2019/08/13/plumber-logging/
read_deepmaps_text <- function(path) {
  delim <- detect_delim(path)
  result <- read.table(path,
    sep = delim,
    header = T,
    row.names = 1
  )
  return(result)
}

#' Read 10x hdf5 format
#'
#' @param path string
#'
#' @return dataframe/matrix/sparse matrix
#'
#' @references https://rviews.rstudio.com/2019/08/13/plumber-logging/
read_deepmaps_h5 <- function(path) {
  result <- Read10X_h5(path)
  return(result)
}


#' Automatically detect delimiters in a text file
#'
#' This helper function was written expressly for \code{\link{set_physical}} to
#' be able to automate its \code{recordDelimiter} argument.
#'
#' @param path (character) File to search for a delimiter
#' @param nchar (numeric) Maximum number of characters to read from disk when
#' searching
#'
#' @return (character) If found, the delimiter, it not, \\r\\n
detect_delim <- function(path, nchar = 1e3) {
  # only look for delimiter if the file exists
  if (file.exists(path)) {
    # readChar() will error on non-character data so
    chars <- tryCatch(
      {
        readChar(path, nchar)
      },
      error = function(e) {
        NA
      }
    )

    search <- regexpr("[,|\\t|;||]+", chars, perl = TRUE)

    if (!is.na(search) && search >= 0) {
      return(substr(chars, search, search + attr(search, "match.length") - 1))
    }
  }
  # readChar() will error on non-character data so


  "\r\n"
}
