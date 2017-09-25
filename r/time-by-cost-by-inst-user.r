#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

if (length(args)!=2) {
  cat("time-by-cost-by-inst institution YYYY-MM\n")
  return(NA)
}

inst <- args[1]
period <- args[2]

source("r/simpletemplate.r")
source("r/dbtools.r")


db <- "thomas"
dba <- "thomas_sgelogs"

keys <- genkeys(c("%INSTITUTE%"), c(inst))
query <- templatefile("sql/ist-to-users.sql", keys)
users <- dbquery(db, query)

results <- data.frame(inst = character(), single=numeric(0), optimal=numeric(0), big=numeric(0))

for (a in users$username) {

    userlimits <- onlimits(a)

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
    
    if ((!is.na(usage)) && (!is.na(goodusage)) && (!is.na(bigusage))){
      results <- rbind(results, tempframe)
    }

} 
names(results)<-c("User", "Single", "Target", "Large")
results[is.na(results)] <- 0
write.csv(results)
