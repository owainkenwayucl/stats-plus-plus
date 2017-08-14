# stats-plus-plus
My latest attempt to have some useful stats tools for our services.

This is a set of tools that can hopefully be used to write useful just in time stats programs to fulfil the arbitrary requirements we sometimes get.  I'm basing it on the stuff I did in the tailoredrcstats (https://github.com/UCL-RITS/tailoredrcstats) package with the aim of having a more generic set of stuff.

## Requirements

### Python

* Python 3
* `mysqlclient` from PyPi (or the matching package from the Ubuntu repos)

### R

* R
* RMySQL

## Examples

Here's an example of the kind of thing you can do now in R:

```R
source("r/simpletemplate.r")
source("r/dbtools.r")

keys <- genkeys(c("%DB%", "%PERIOD%"), c("thomas_sgelogs", "2017-08"))
query <- templatefile("sql/mean-slowdown-by-user.sql", keys)
data <- dbquery("thomas_sgelogs", query)
```

What's happening here is we are setting some parameters for the `mean-slowdown-by-user` SQL query, namely which service and the time period (August 2017), using my templating library to put them into the query, passing that query to the database and getting back an R data object which we can do the usual R tricks on.

The equivalent in Python3 looks like this:

```Python
import simpletemplate as st 
import dbtools as dbt 

keys = {'%DB%':'thomas_sgelogs', '%PERIOD%':'2017-08'}
query = st.templatefile(filename='sql/mean-slowdown-by-user.sql', keys=keys)
data = dbt.dbquery(db='thomas_sgelogs', query=query)
```