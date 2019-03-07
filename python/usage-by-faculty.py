'''
   Tool to generate historical usage by faculty.
'''

def genfacstats(service, today, sep='|', nmonths=12, DEBUG=False):
    import dbtools.facultymapper as fm 
    import dbtools.datemapper as dm
    import dbtools as dbt
    import simpletemplate as st 
    import datetime
    import sys

    dbt.DEBUG = DEBUG

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
        usage = {}
        d = dbt.sqllist(fmap[f])
        keys = {'%DB%':service_db, '%DEPARTMENT%':d}
        query = st.templatefile(filename="sql/facultyusage.sql", keys=keys)
        results = dbt.dbquery(db=keys['%DB%'], query=query)
       
        for i in range(1,nmonths+1):
            txtdate=dm.datetoperiod(months[i])
            usage[txtdate] = 0
            for j in results:
                if j["Period"] == txtdate:
                    usage[txtdate] = dbt.undecimal(j["Total CPU Time Usage"])

        for i in range(1,nmonths+1):
            txtdate=dm.datetoperiod(months[i])
            print(usage[txtdate], end=sep)
        print("")

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

    parser = argparse.ArgumentParser(description="Generate CSV of faculty use for 12 months.")
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

    genfacstats(service, today, sep, nmonths, DEBUG)