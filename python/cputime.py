#!/usr/bin/env python3

# Print out the usage on a particular system in a given period.

def gettime(service, today, sep, nmonths, DEBUG):
    import dbtools.datemapper as dm
    import dbtools as dbt
    import simpletemplate as st 

    import datetime
    import sys

    dbt.DEBUG = DEBUG

    service_db = dbt.SERVICE_DB[service.lower()]
    monthstart = datetime.date(today.year, today.month, 1)
    lastmonthend = dm.subtractmonth(monthstart)
    

    # Get the last 12 months.
    months = dm.getlastnmonths(monthstart, nmonths)
    total = 0
    print("Month" + sep+ "Time(h)" + sep)
    for a in reversed(list(months.keys())): 
        period = dm.datetoperiod(months[a])
        keys = {'%DB%':service_db, '%PERIOD%':period}
        query = st.templatefile(filename="sql/usage.sql", keys=keys)

        results = dbt.dbquery(db=keys['%DB%'], query=query)
        t = dbt.undecimal(results[0]['sum((run_time*cost))'])/3600
        total+=t
        print(period + sep + str(t) + sep)

    print("Total" + sep + str(total) + sep)
    print("Average" + sep + str(total/nmonths) + sep)

if __name__ == '__main__':
    import argparse
    import datetime
    import dbtools.datemapper as dm

        # Default values
    service="grace"
    today = datetime.date.today()
    sep = "|"
    nmonths = 12
    DEBUG=False 

    parser = argparse.ArgumentParser(description="Generate CSV of CPU use for 12 months.")
    parser.add_argument('-d', metavar='date', type=str, help="Date to count back from.")
    parser.add_argument('-s', metavar='sep', type=str, help="CSV seperator (default: |)")
    parser.add_argument('-c', metavar='cluster', type=str, help="Cluster to generate stats for (default: grace)")
    parser.add_argument('-m', metavar='months', type=int, help="Number of months to count back (default: 12)")
    parser.add_argument('-v', action='store_true', help='Print out debugging info.')

    args = parser.parse_args()

    if args.d != None:
        today = dm.fromisoformat(args.d)

    if args.s != None:
        sep = args.s

    if args.c != None:
        service = args.c 

    if args.m != None:
        nmonths=args.m

    if args.v == True:
        DEBUG = True

    gettime(service, today, sep, nmonths, DEBUG)