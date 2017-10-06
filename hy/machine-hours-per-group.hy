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

(setv keys {"%DB%" "thomas_sgelogs" "%PROJECT%" inst "%PERIOD%" period})
(setv query (simpletemplate.templatefile 
                           :filename "sql/machine-hours-per-group.sql"
                           :keys keys))
(setv data (dbtools.dbquery :db (get keys "%DB%")
                           :query query))

(setv njobs (get (get data 0) "num_jobs"))
(setv mhours (get (get data 0) "machine_hours"))
(setv chours (get (get data 0) "core_hours"))

(print (+ "         Jobs: " (str njobs)))
(print (+ "Machine hours: " (str mhours)))
(print (+ "    CPU hours: " (str chours)))