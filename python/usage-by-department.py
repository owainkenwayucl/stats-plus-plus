
def gendeptstats(service, today, sep='|', nmonths=12, DEBUG=False):
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

    print("Dept", end=sep)
    for i in range(1,nmonths+1):
        print(dm.datetoperiod(months[i]), end=sep)
    print("")


    keys = {'%DB%':service_db}
    query = st.templatefile(filename="sql/cputime-by-department.sql", keys=keys)
    results = dbt.dbquery(db=keys['%DB%'], query=query)

    departments=[]
    for a in results:
        if a["Department"] not in departments:
            departments.append(a["Department"])

    for a in departments:
        print(a, end=sep)
        for b in months.keys():
            d=False
            for c in results:
                if c["Department"] == a and c["Period"] == dm.datetoperiod(months[b]):
                    print(c["Total CPU Time Usage"], end=sep)
                    d=True
            if not d:
                print("0",end=sep)
        print("")


if __name__ == '__main__':
    import argparse
    import datetime

    # Default values
    service="grace"
    today = datetime.date.today()
    sep = "|"
    nmonths = 12
    DEBUG=False 

    parser = argparse.ArgumentParser(description="Generate CSV of department use for 12 months.")
    parser.add_argument('-d', metavar='date', type=str, help="Date to count back from.")
    parser.add_argument('-s', metavar='sep', type=str, help="CSV seperator (default: |)")
    parser.add_argument('-c', metavar='cluster', type=str, help="Cluster to generate stats for (default: grace)")
    parser.add_argument('-m', metavar='months', type=int, help="Number of months to count back (default: 12)")
    parser.add_argument('-v', action='store_true', help='Print out debugging info.')

    args = parser.parse_args()

    if args.d != None:
        today = args.d

    if args.s != None:
        sep = args.s

    if args.c != None:
        service = args.c 

    if args.m != None:
        nmonths=args.m

    if args.v == True:
        DEBUG = True

    gendeptstats(service, today, sep, nmonths, DEBUG)