# Print out the unique users over all services over all time.

import dbtools as dbt
import simpletemplate as st 

keys = {}
query = st.templatefile(filename="sql/allusersalltime.sql", keys=keys)
results = dbt.dbquery(query=query)

print("Period|Users")
for a in results:
    print(a['Period'] + "|" + str(a['Total Users']))