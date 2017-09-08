# Generic query wrapper to keep the MySQL nastiness out of the code.
dbquery <- function(db, query, mysqlhost="mysql.external.legion.ucl.ac.uk", mysqlport = 3306) {

# Pull in the RMySQL library and my tool for reading Python ini files.
  (library(RMySQL))
  source("r/rini.r")

# Get authentication information.
  authdetails <- rinisect("~/.stats_secrets/accounts", "database")

  con <- dbConnect(MySQL(),
                 user = authdetails['user'],
                 password = authdetails['pass'],
                 dbname = db,
                 host = mysqlhost,
                 port = mysqlport)

  on.exit(dbDisconnect(con))

  q <- dbSendQuery(con, query)
  data <- fetch(q)
  stat <- dbHasCompleted(q)

  dbClearResult(q)

  return(data)
}

# Convert list-like structures to an SQL list.
sqllist <- function(rlist) {
  sqlstr <- "("

  if (typeof(rlist) == "character") {
    sqlstr <- paste(sqlstr, "'", collapse="")
    sqlstr<-paste(sqlstr, rlist, collapse="")
    sqlstr <- paste(sqlstr, "'", collapse="")
  } else {
    for (a in rlist) {
      if (sqlstr != "(") {
        sqlstr <- paste(sqlstr, ",", collapse="")
      }
      sqlstr <- paste(sqlstr, "'", collapse="")
      sqlstr <- paste(sqlstr, a, collapse="")
      sqlstr <- paste(sqlstr, "'", collapse="")
    }
  }
  sqlstr <- paste(sqlstr, ")", collapse="")
  return(sqlstr)
}


# Build owner limit string for queries.
onlimits <- function(users="*") {
  query <- ""

# If we don't have the default value, build a limit on the query.
  if (users != "*") {
    userlist <- sqllist(users)
    query <- paste(query, " and owner in ", collapse="")
    query <- paste(query, userlist, collapse="")
  }

  return(query)
}