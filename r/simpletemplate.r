# Replace values in a string with values from a vector where names(keys)
# contains the keys, and the keys contains the values.
templatestring <- function(s, keys) {
  r <- s
  for (a in names(keys)) {
    r <- gsub(a, keys[a], r)
  }
  return(r)
}

# Version with file instead of string.
templatefile <- function(filename, keys) {
  x <- readChar(filename, file.info(filename)$size)
  return(templatestring(x, keys))
}

# Simplify making a matched pair of vectors for keys.
genkeys <- function(names, values) {
  r <- values
  names(r) <- names
  return(r)
}