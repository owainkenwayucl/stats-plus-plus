'''
   This module contains routines for manipulating dates, which will be treated as a tuple of year:month.
   Keeping this code in one place should solve the old stats problem of 32903 different incompatible 
   implementations.
'''

import datetime


# For reasons datetime doesn't include a sane way of subtracting a month.
# Returns new date d.year, d.month - 1, d.day with overflows.
def subtractmonth(d):
    firstday = datetime.date(d.year, d.month, 1)
    lastmonth = firstday-(datetime.timedelta(days=1))
    retval = datetime.date(lastmonth.year, lastmonth.month,min(d.day, lastmonth.day))
    return retval

def getlast12months(d):

    return getlastnmonths(d,12)

# NOTE Keys are accidentally sorted in reverse order!
def getlastnmonths(d,n):
    retval={}
    temp = d

    for i in range(n, 0, -1):
        temp = subtractmonth(temp)
        retval[i] = temp

    return retval

def datetoperiod(d):
    m = str(d.month)
    if len(m)==1:
        m = "0"+m
    return "" + str(d.year) + "-" + m

def fromisoformat(d):
    return datetime.datetime.strptime(d, "%Y-%m-%d")