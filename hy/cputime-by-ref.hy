;(dbtools.log (str monthlist) "Months")

(defn getusageref [service monthlist refs debug] 
	(import simpletemplate)
	(import dbtools)
	(import dbtools.datemapper)
	(setv dbtools.DEBUG debug)

	(setv reflist (dbtools.sqllist refs))

	(setv keys {"%DB%" (+ service "_sgelogs") "%PERIOD%" "2021-01" "%REFCAT%" reflist})
	(setv query (simpletemplate.templatefile
                           :filename "sql/cputime-for-refs.sql"
                           :keys keys))



	(setv data (dbtools.dbquery :db (get keys "%DB%")
                           :query query))

	data
)

(defn printCSV [monthlist refs data seperator] 
	(import simpletemplate)
	(import dbtools)
	(import dbtools.datemapper)

	(print ">>> CSV:")
	(print "Ref Category" seperator :end "")
	(for [a refs]
		(print a :end seperator)
	)
	(print "")
	(print "Period" seperator "Usage (h)")
	(for [i (range nmonths)]
		(setv index (+ i 1))
		(setv pperiod (dbtools.datemapper.datetoperiod (get monthlist index)))
		(print pperiod :end seperator)
		(for [a refs]
          		(setv value 0.0)
          		(for [b data]
				(if (and (= (get b "Period") pperiod) (= (get b "ref_category") a)) (setv value(get b "Total CPU Time Usage")))
          		)
          		(print value :end seperator)
		)
		(print "")

	)
)


;; This is our main function.
(defmain [&rest args]
	(import dbtools.datemapper)


	(setv platform "myriad")
	(setv artrefcat ["Education" "Business and Management Studies" "Politics and International Studies" "Sociology" "Economics and Econometrics" "Philosophy" "Modern Languages and Linguistics" "Communication, Cultural and Media Studies, Library and Information Management" "Law" "Geography, Environmental Studies and Archaeology" "Psychology, Psychiatry and Neuroscience" "Architecture, Built Environment and Planning"])

	(setv nmonths 36)
	(setv current (dbtools.datemapper.fromisoformat "2021-02-01"))
	(setv monthlist (dbtools.datemapper.getlastnmonths current nmonths))
	(setv seperator " | ")

	(setv data (getusageref platform monthlist artrefcat True))
	(printCSV monthlist artrefcat data seperator)

)

