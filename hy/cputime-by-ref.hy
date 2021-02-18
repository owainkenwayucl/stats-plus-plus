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



	(setv data (dbtools.dbquery 
				:db (get keys "%DB%")
				:query query))

	data
)

(defn printCSV [monthlist refs data seperator debug] 
	(import simpletemplate)
	(import dbtools)
	(import dbtools.datemapper)

	(setv nmonths (len monthlist))

	(if debug (print ">>> CSV:"))
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

(defn getrefcats [debug]
	(import simpletemplate)
	(import dbtools)
	(setv dbtools.DEBUG debug)

	(setv query (simpletemplate.templatefile
		:filename "sql/refcats.sql"
                :keys {})

	)
	(setv data (dbtools.dbquery 	
				:db "user_info"
                           	:query query))

	(setv retval [])
	(for [a data] 
		(.append retval (get a "ref_category"))
	)
	(if debug (dbtools.log retval "Categories found:"))
	retval
)

;; This is our main function.
(defmain [&rest args]
	(import dbtools.datemapper)
	(import argparse)
	(import datetime)
	(import json)


;; Defaults
	(setv platform "myriad")
	(setv artrefcat ["Education" "Business and Management Studies" "Politics and International Studies" "Sociology" "Economics and Econometrics" "Philosophy" "Modern Languages and Linguistics" "Communication, Cultural and Media Studies, Library and Information Management" "Law" "Geography, Environmental Studies and Archaeology" "Psychology, Psychiatry and Neuroscience" "Architecture, Built Environment and Planning"])


	(setv nmonths 36)
	(setv current (datetime.date.today))
	(setv seperator "|")
	(setv debug False)

	(setv parser (argparse.ArgumentParser :description "Generate CPU usage for a named list of REF categories."))

	(parser.add_argument "-d" 	:metavar "date"
				  	:type str
				  	:help "Date to cound back from (default: today)")

	(parser.add_argument "-s" 	:metavar "seperator"
					:type str
					:help "CSV seperator (default |)")

	(parser.add_argument "-c"	:metavar "cluster"
					:type str
					:help "Cluster (default: myriad)")

	(parser.add_argument "-m"	:metavar "months"
					:type int
					:help "Number of months to count back (default: 36)")
	(parser.add_argument "-r"	:metavar "refcats"
					:type str
					:help "JSON formatted list of REF categories (default: list of Arts and Humanities REF categories)")

	(parser.add_argument "-v" 	:action "store_true"
				  	:help "Print out debugging information")


	(setv args (parser.parse_args))

	(if args.v (setv debug True))

	(if (!= None args.d) (setv current (dbtools.datemapper.fromisoformat args.d)))
	(if (!= None args.s) (setv seperator args.s))
	(if (!= None args.c) (setv platform args.c))
	(if (!= None args.m) (setv nmonths args.m))

	(setv refcat (getrefcats debug)) 

	(if (!= None args.r) (if (= "arts" args.r) (setv refcat artrefcat) (setv refcat (json.loads args.r))))

	(setv monthlist (dbtools.datemapper.getlastnmonths current nmonths))

	(setv data (getusageref platform monthlist refcat debug))
	(printCSV monthlist refcat data seperator debug)

)

