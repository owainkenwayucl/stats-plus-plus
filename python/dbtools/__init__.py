'''
    This library provides database access routines.

    It's based on the re-usable parts of tailoredstats.
    
    Owain Kenway
'''

'''
    Generally abstract away DB queries, such that all complexity is replaced with:
    
        dbtools.dbquery(db, query)
'''
def dbquery(db, query, mysqlhost="mysql.external.legion.ucl.ac.uk", mysqlport = 3306 ):
    from auth.secrets import Secrets
    import MySQLdb   # Note need mysqlclient package from pypi

    # Set up our authentication.
    s = Secrets()

    # Connect to database.
    conn = MySQLdb.Connect(host=mysqlhost,
                           port=mysqlport,
                           user=s.dbuser,
                           passwd=s.dbpasswd,
                           db=db)

    # Set up cursor.
    cursor = conn.cursor(MySQLdb.cursors.DictCursor)

    print(">>> DEBUG SQL query: " + query)

    # Run query.
    cursor.execute(query)

    # Dump output.
    output = cursor.fetchall()

    # Tidy up.
    cursor.close()
    conn.close()

    return output


# Generate a valid SQL list from a python one.
def sqllist(pylist):
    sqlstr="("
    if type(pylist) == str:
        sqlstr = sqlstr + "'" + pylist + "')"
    else:
        for a in pylist:
            if sqlstr!= "(":
                sqlstr = sqlstr + ", "
            sqlstr = sqlstr + "'" + a + "'"
        sqlstr = sqlstr + ")"
    return sqlstr