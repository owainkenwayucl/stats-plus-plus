'''
    This library provides database access routines.

    It's based on the re-usable parts of tailoredstats.
    
    Owain Kenway
'''

# Flag to enable debug output.
DEBUG = False

# Map servicenames to db names.
SERVICE_DB = {"kathleen":"kathleen_sgelogs","grace":"grace_sgelogs", "legionold":"sgelogs2", "legion":"legion_sgelogs", "myriad":"myriad_sgelogs", "thomas":"thomas_sgelogs", "michael":"michael_sgelogs", "young":"young_sgelogs"}

'''
    Generally abstract away DB queries, such that all complexity is replaced with:
    
        dbtools.dbquery(db, query)
'''
def dbquery(db="", query="", mysqlhost="mysql.rc.ucl.ac.uk", mysqlport = 3306 ):
    from auth.secrets import Secrets
    import mysql.connector # Use the "official" MySQL connector
    import datetime
    #import sys

    # Set up our authentication.
    s = Secrets()

    # Connect to database.
    conn = mysql.connector.connect(host=mysqlhost,
                           port=mysqlport,
                           user=s.dbuser,
                           password=s.dbpasswd,
                           database=db)

    # Set up cursor.
    cursor = conn.cursor(dictionary=True)

    # Debug line.
    if DEBUG:
        log(query, "SQL query")

    # Timing.
    starttime=datetime.datetime.now()

    # Run query.
    cursor.execute(query)

    # Dump output.
    output = cursor.fetchall()

    # Timing.
    endtime=datetime.datetime.now()
    if DEBUG: 
        log(str(endtime - starttime), "Time taken")

    # Tidy up.
    cursor.close()
    conn.close()

    return output

# Routine for "pretty" logging.
def log(s, t=""):
    import sys

    lines = s.splitlines()

    if len(t) > 0:
        t = " " + t

    if len(lines) ==  1:
        sys.stderr.write(">>> DEBUG" + t + ": " + s + "\n")
    else:
        sys.stderr.write(">>> DEBUG" + t + ":\n")
        for line in lines:
            sys.stderr.write("... " + line + "\n")


# Generate a valid SQL list from a python one.
def sqllist(pylist):
    sqlstr="("
    if type(pylist) == str:
        sqlstr = sqlstr + '"' + pylist + '")'
    else:
        for a in pylist:
            if sqlstr!= "(":
                sqlstr = sqlstr + ", "
            sqlstr = sqlstr + '"' + a + '"'
        sqlstr = sqlstr + ")"
    return sqlstr


# Build owner limit string for queries.
def onlimits(users="*"):
    query = ""

    # if users != * then construct a user list.
    if users != "*":
        userlist = sqllist(users)
        query = query + " and owner in " + userlist

    return query

# Pull a list of values for a field from a dict.
def unpackresults(results, key):
    r = []
    for a in results:
        r.append(a[key])
    return r

# Convert potentially null decimal numbers to floats.
def undecimal(n):
    r = 0.0
    if type(n) != type(None):
        r = float(n)
    return r

# Work out which service we are on.
def getservice():
    import socket
    services = ["grace", "legion", "myriad", "thomas", "kathleen", "young"]
    for a in socket.gethostbyaddr(socket.gethostname()):
        for b in services:
            if b in a:
                return b
    return "UNKNOWN"
