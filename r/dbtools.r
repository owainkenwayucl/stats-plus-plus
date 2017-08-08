# Generic query wrapper to keep the MySQL nastiness out of the code.
dbquery <- function(db, query, mysqlhost="mysql.external.legion.ucl.ac.uk", mysqlport = 3306) {

# Pull in the RMySQL library and my tool for reading Python ini files.
  (library(RMySQL))
  source("r/pyconfconv.r")

# Get authentication information.
  eval(parse(text=pyconfconverts("~/.stats_secrets/accounts", "database")))

  con <- dbConnect(MySQL(),
                 user = user,
                 password = pass,
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