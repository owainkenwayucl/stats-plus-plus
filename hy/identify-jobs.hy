;; Tool to categorise jobs based on their archived job script.
;; Owain Kenway

; List of fingerprints for known apps.
(setv binaries { 
		 "lammps"           ["lmp"]
		 "vasp"             ["vasp"]
		 "gromacs"          ["mdrun" "gmx"]
		 "namd"             ["namd2"]
		 "castep"           ["castep"]
		 "onetep"           ["onetep"]
		 "cp2k"             ["cp2k"]
		 "nwchem"           ["nwchem"]
		 "dlpoly"           ["dlpoly"]
		 "crystal"          ["cry14" "cry17"]
		 "gamess"           ["gamess"]
		 "python"           ["python" ".py"]
		 "cesm"             ["cesm"]
		 "amber"            ["amber" "pmemd" "mmpbsa"]
		 "openfoam"         ["foam"]
		 "casino"           ["casino"]
		 "chemshell"        ["chemshell"]
		 "quantum espresso" ["pw.x"]
		 "acesim"           ["acesim"]
		 "molpro"           ["molpro"]
		 "xmds"             ["xmds"]
		 "gulp"             ["multigulp"]
		 "r"                ["r cmd batch" "rscript"]
		 "mitgcmuv"         ["mitgcmuv"]
		 "cpmd"             ["cpmd"]
		 "aims"             ["aims"]
		 "siesta"           ["siesta"]
		})


(setv scriptloc {
		 "grace" "/var/opt/sge/shared/saved_job_scripts/"
		 "thomas" "/var/opt/sge/shared/saved_job_scripts/"
		 "legion" "/var/opt/sge/shared/saved_job_scripts/"
		 "myriad" "/var/opt/sge/shared/saved_job_scripts/"
		})

; Convert a job number to a filename based on the service.
(defn setfname [service filename] (+ (get scriptloc service) filename))

; Get the parallel launcher from a given file.
(defn getparaline[filename]
	(setv r "")
	(try 
		(with [f (open filename)]
			(try
				(for [line f] 
					(if (.startswith (.strip line) "export MDR")
						(setv r line))	
					(if (.startswith (.strip line) "UNRES_BIN")
						(setv r line))	
					(if (.startswith (.strip (.upper line)) "EXEC")
						(setv r line))	
					(if (.startswith (.strip line) "mpirun")
						(setv r line))	
					(if (.startswith (.strip line) "gerun")
						(setv r line))	
				)
				(except [UnicodeDecodeError]
					(setv r ""))
			)

		)
		(except [FileNotFoundError] (setv r ""))
	)
	r
)

; Check lowercase containment.
(defn isx [line x]
	(if (in x (.lower line)))
)

; Match a line against our applications.
(defn matchapp [line] 
	(setv r "other")
	(for [a (.keys binaries)]
		(for [b (get binaries a)]
			(if (isx line b) (setv r a))
		)
	)
	r
)

; Query the MySQL DB to get stats for a given service in a given time period.
(defn getjobdata[service period]

	(import simpletemplate)
	(import dbtools)

	(setv keys {"%DB%" (+ service "_sgelogs") "%PERIOD%" period})
	(setv query (simpletemplate.templatefile
					:filename "sql/jobs-period.sql"
					:keys keys))

	(setv data (dbtools.dbquery 
					:db (get keys "%DB%")
				    :query query))

	data
)

; Perform our query, get job data, return a list of apps vs. cpu time.
(defn getusagebyapp [service period]
	(import dbtools)

	; Set up results dict
	(setv results {"other" 0})
	(for [a (.keys binaries)]
		(assoc results a 0)
	)	

	; Perform our query
	(setv dbdata (getjobdata service period))
	
	; Step through results adding to the right applications.
	(for [a dbdata]
		(setv id (get a "job_number"))
		(setv seconds (* (get a "cost") (- (get a "end_time")(get a "start_time"))))
		(setv label (matchapp (getparaline (setfname service (str (get a "job_number"))))))
		(assoc results label (+ (get results label) seconds))
	)	

	; Convert to hours.
	(for [a (.keys results)]
		(assoc results a (/ (dbtools.undecimal (get results a)) 3600))
	)

	results	
)

; Produce csv output for importing into speadsheets etc.
(defn csvout [service period results]
	(setv sortedkeys (sorted (.keys binaries)))
	(.append sortedkeys "other")
	(print (+ service "," period ","))
	(print "code,time(h)")
	(for [a sortedkeys]
		(print (+ a "," (str (get results a)) ","))
	)
)

; In hy this is our main.  Run the program with the period (YYYY-mm) you want to get data for.
; Note, due to the scripts being on the filesystem you need to run this on the host you want
; data for.
(defmain [&rest args]
	(import dbtools)
	(import sys)

	(setv service (dbtools.getservice))
	(if (= service "UNKNOWN") 
		(do
			(print "This tool needs to be run on an RC service.")
			(sys.exit 1)
		)
	)

	(if (> 2 (len args))
		(do
			(print "Run with period as first argument.")
			(sys.exit 2)
		)
		(csvout service (get args 1) (getusagebyapp service (get args 1)))
	)
)
