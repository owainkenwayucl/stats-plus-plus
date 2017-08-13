# Read in an ini file and map it to a table.
rini <- function(filename, section) {

  ns <- c()
  values <- c()

  parasect <-paste('[', section, ']', sep='')
  insect <- FALSE
  con <- file(filename, "r")
  while (length(ln <- readLines(con, n=1)) > 0) {
    ldata <- trimws(ln)
    if (nchar(ldata)>0) {
      if (substr(ldata,1,1) == '[') {
        if (ldata == parasect) {
          insect <- TRUE
        } else {
          insect <- FALSE
        }
      } else {
        if (insect) {
          v <- unlist(strsplit(ldata, ":"))
          name <- v[1]
          value <- v[2]

# need to deal with case where data contains ':'
          if (length(v) > 2) {
            for (a in 3:length(v)) {
              value <- paste(value, v[a], sep=':')
            }
          }
          ns <- c(ns, name)
          values <- c (values, trimws(value))
        }
      }
    }
  }
  names(values) <- ns
  close(con)
  return(values)
}
