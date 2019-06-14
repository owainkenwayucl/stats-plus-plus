#!/usr/bin/env python3

# Print out a list of users in a given department.
# Useful for department-specific ACLs.

import dbtools as dbt
import simpletemplate as st 
import sys

if len(sys.argv) < 2:
    print("Usage: " + sys.argv[0] + " \"department\"")
    sys.exit(1)

service_db = "myriad_sgelogs"
d = dbt.sqllist(sys.argv[1])

keys = {'%DB%':service_db, '%DEPARTMENT%':d}
query = st.templatefile(filename="sql/facultyusers.sql", keys=keys)

results = dbt.dbquery(db=keys['%DB%'], query=query)

for a in results:
    print(a['username'])