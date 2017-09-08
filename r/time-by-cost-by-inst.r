#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

if (length(args)!=1) {
  cat("jsperinst YYYY-MM\n")
  return(NA)
}
period <- args

source("r/simpletemplate.r")
source("r/dbtools.r")


db <- "thomas"
dba <- "thomas_sgelogs"

# Get table of institutions.
query <- "select inst_id from thomas.institutes"
insts <- dbquery(db, query)

results <- data.frame(inst = character(), single=numeric(0), optimal=numeric(0), big=numeric(0))


for (a in insts$inst_id) {
    keys <- genkeys(c("%INSTITUTE%"), c(a))
    query <- templatefile("sql/ist-to-users.sql", keys)
    users <- dbquery(db, query)
    userlimits <- onlimits(users$username)

    keys <- genkeys(c("%DB%", "%PERIOD%", "%LOWERCOST%", "%UPPERCOST%", "%ONLIMITS%"), c(dba, period, "1", "24", userlimits))
    query <- templatefile("sql/usage-cost-opts.sql", keys)
    usage <- dbquery(dba, query)

    keys <- genkeys(c("%DB%", "%PERIOD%", "%LOWERCOST%", "%UPPERCOST%", "%ONLIMITS%"), c(dba, period, "25", "120", userlimits))
    query <- templatefile("sql/usage-cost-opts.sql", keys)
    goodusage <- dbquery(dba, query)

    keys <- genkeys(c("%DB%", "%PERIOD%", "%LOWERCOST%", "%UPPERCOST%", "%ONLIMITS%"), c(dba, period, "121", "10000000", userlimits))
    query <- templatefile("sql/usage-cost-opts.sql", keys)
    bigusage <- dbquery(dba, query)

    tempframe <- data.frame(inst=a, single=usage, optimal=goodusage, big=bigusage)
    results <- rbind(results, tempframe)

} 
names(results)<-c("Institution", "Single", "Target", "Large")
results[is.na(results)] <- 0
write.csv(results)
