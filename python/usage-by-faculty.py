'''
   Tool to generate historical usage by faculty.
'''

def genfacstats(service, today, sep='|', nmonths=12):
    import dbtools.facultymapper as fm 
    import dbtools.datemapper as dm
    import dbtools as dbt
    import simpletemplate as st 
    import datetime
    import sys

    # Get the latest faculty map.
    fmap = fm.getmap()

    service_db = dbt.SERVICE_DB[service.lower()]

    monthstart = datetime.date(today.year, today.month, 1)
    lastmonthend = dm.subtractmonth(monthstart)

    # Get the last 12 months.
    months = dm.getlastnmonths(monthstart, nmonths)

    print("Faculty", end=sep)
    for i in range(1,nmonths+1):
        print(dm.datetoperiod(months[i]), end=sep)
    print("")


    # we need to loop over faculties and dates, querying to get the sum for each period.
    for f in sorted(fmap.keys()):
        print(f, end=sep)
        for i in range(1,nmonths+1):
            total = 0
            for d in fmap[f]:
                keys = {'%DB%':service_db, '%PERIOD%':dm.datetoperiod(months[i]), '%DEPARTMENT%':d}
                query = st.templatefile(filename="sql/time-by-dept.sql", keys=keys)
                total = total + (dbt.undecimal(dbt.dbquery(db=keys['%DB%'], query=query)[0]['SUM(cost*run_time)']))
            print(total, end=sep)
        print("")

if __name__ == '__main__':
    import argparse
    import datetime

    # Default values
    service="grace"
    today = datetime.date.today()
    sep = "|"
    nmonths = 12

    parser = argparse.ArgumentParser(description="Generate CSV of faculty use for 12 months.")
    parser.add_argument('-d', metavar='date', type=str, help="Date to count back from.")
    parser.add_argument('-s', metavar='sep', type=str, help="CSV seperator (default: |)")
    parser.add_argument('-c', metavar='cluster', type=str, help="Cluster to generate stats for (default: grace)")
    parser.add_argument('-m', metavar='months', type=int, help="Number of months to count back (default: 12)")

    args = parser.parse_args()

    if args.d != None:
        today = args.d

    if args.s != None:
        sep = args.s

    if args.c != None:
        service = args.c 

    if args.m != None:
        nmonths=args.m

    genfacstats(service, today, sep, nmonths)