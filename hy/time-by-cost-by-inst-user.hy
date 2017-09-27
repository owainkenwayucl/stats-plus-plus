(import simpletemplate)
(import dbtools)
(import sys)

(if (< (len sys.argv) 2)
  (do (setv usage (+ "Usage: " (+ (get sys.argv 0) " <Institute> <YYYY-MM>")))
      (print usage) 
      (sys.exit 1))
)

(setv inst (get sys.argv 1))
(setv period (get sys.argv 2))

(setv db "thomas")
(setv dba "thomas_sgelogs")

(setv keys {"%INSTITUTE%" inst})
(setv query (simpletemplate.templatefile :filename "sql/ist-to-users.sql" :keys keys))
(setv users (set (dbtools.unpackresults (dbtools.dbquery :db db :query query) "username")))

(setv results {})

(for [i users]
  (setv limits (dbtools.onlimits :users i))
  
  (setv keys {"%DB%" dba "%PERIOD%" period "%LOWERCOST%" 1 "%UPPERCOST%" 24 "%ONLIMITS%" limits})
  (setv query (simpletemplate.templatefile :filename "sql/usage-cost-opts.sql" :keys keys))
  (setv singlenodeusage (dbtools.undecimal (get (dbtools.unpackresults (dbtools.dbquery :db dba :query query) "sum((run_time*cost))/3600") 0)))

  (setv keys {"%DB%" dba "%PERIOD%" period "%LOWERCOST%" 25 "%UPPERCOST%" 120 "%ONLIMITS%" limits})
  (setv query (simpletemplate.templatefile :filename "sql/usage-cost-opts.sql" :keys keys))
  (setv idealusage (dbtools.undecimal (get (dbtools.unpackresults (dbtools.dbquery :db dba :query query) "sum((run_time*cost))/3600") 0)))

  (setv keys {"%DB%" dba "%PERIOD%" period "%LOWERCOST%" 121 "%UPPERCOST%" 10000000 "%ONLIMITS%" limits})
  (setv query (simpletemplate.templatefile :filename "sql/usage-cost-opts.sql" :keys keys))
  (setv bigusage (dbtools.undecimal (get (dbtools.unpackresults (dbtools.dbquery :db dba :query query) "sum((run_time*cost))/3600") 0)))

  (setv (get results i) {"Single" singlenodeusage "Ideal" idealusage "Big" bigusage})
)

(print "Username,Single Node,Ideal Size,Big")
(for [i users]
  (print i :end ",")
  (print (get (get results i) "Single") :end ",")
  (print (get (get results i) "Ideal") :end ",")
  (print (get (get results i) "Big"))
)