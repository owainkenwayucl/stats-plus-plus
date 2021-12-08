;; Tool to categorise jobs based on their archived job script.
;; Owain Kenway

; List of fingerprints for known apps.
(setv binaries { 
		"lammps"           ["lmp" "lammps"]
		"vasp"             ["vasp"]
		"gromacs"          ["mdrun" "gmx"]
		"namd"             ["namd2"]
		"castep"           ["castep"]
		"onetep"           ["onetep"]
		"cp2k"             ["cp2k"]
		"nwchem"           ["nwchem"]
		"dlpoly"           ["dlpoly"]
		"crystal"          ["cry14" "cry17"]
		"crystalpredictor" ["CrystPred"]
		"gamess"           ["gamess"]
		"python"           ["python" ".py"]
		"cesm"             ["cesm"]
		"amber"            ["amber" "pmemd" "mmpbsa"]
		"openfoam"         ["foam" "snappyHexMesh"]
		"octopus"          ["$Oct" "OCTO_EXEC" "octopus"]
		"casino"           ["casino"]
		"chemshell"        ["chemshell" "chemsh"]
		"quantum espresso" ["pw.x" "ph.x" "neb.x" "bands.x"]
		"acesim"           ["acesim"]
		"molpro"           ["molpro"]
		"xmds"             ["xmds"]
		"gulp"             ["multigulp"]
		"r"                ["r cmd batch" "rscript"]
		"mitgcmuv"         ["mitgcmuv"]
		"cpmd"             ["cpmd"]
		"aims"             ["aims"]
		"cspy"             ["csp"]
		"siesta"           ["siesta"]
		"klmc"             ["klmc"]
		"phylobayes"       ["pb_mpi"]
		"specfem3d"        ["xspecfem3d"]
		"unknown code 4"   ["ensga2r"]
		"ramses"           ["ramses"]
		"gaussian"         ["g16" "g09"]
		"starcd/starccm"   ["star " "starccm+"]
		"ansys"            ["cfx5solve" "fluent" "ansysdt"]
		"matlab"           ["matlab"]
		"abaqus"           ["abaqus"]
		"cfd-ace"          ["cfd-solver"]
		"gambit"           ["gambit"]
		"vampire"          ["vampire"]
		"conquest"         ["conquest"]
		"neci"             ["neci"]
		"wannier"          ["wannier90.x"]
		"elk"              ["elk"]
		"mango"            ["$mango"]
		"jasmine"          ["jasmine"]
		"optados"          ["optados"]
		"unknown code 1"   ["sgpe_lower_polariton_cont"]
		"unknown code 2"   ["main_code"]
		"unknown code 3"   ["psc_whistler"]
		"unknown code 5"   ["uspex"]
		"unknown code 6"   ["mcsqs"]
		"unknown code 7"   ["calypso.x"]
		"unknown code 8"   ["run_solver"]
		"unknown code 9"   ["abinit"]
		"unknown code 10"  ["dynamic.x"]
		"yambo"            ["yambo"]
		"dftb+"            ["dftb+" "dftb_opt.sh"]
		"taskfarmer"       ["taskfarmer"]
		"boffin"           ["boffin"]
		"denise"           ["denise"]
		"orca"             ["orca" "ORCA"]
		})


(setv scriptloc {
		"grace" "/var/opt/sge/shared/saved_job_scripts/"
		"thomas" "/var/opt/sge/shared/saved_job_scripts/"
		"legion" "/var/opt/sge/shared/saved_job_scripts/"
		"myriad" "/var/opt/sge/shared/saved_job_scripts/"
		"kathleen" "/var/opt/sge/shared/saved_job_scripts/"
                "young" "/var/opt/sge/shared/saved_job_scripts/"
		})

; Common starts of line that indicate the code
(setv launchers ["export MDR" "export CMD" "CMD=" "export PW" "PW=" "EXEC=" "export EXEC" "UNRES_BIN" "chemsh" "g16" "g09" "star" "cfx5solve" "fluent" "R " "Rscript " "python" "matlab" "gmx" "USPEX" "mcsqs" "time" "./ramses2gadget" "abaqus" "CFD-SOLVER" "mdrun" "/usr/bin/time" "$HOME/bin" "${HOME}/bin" "${HOME}/src" "$HOME/src" "./calypso.x" "ansysdt" "wfl"])

(setv directs ["cp2k." "orca" "dftp_opt"])

(setv excludes (, "#" "echo"))

; Convert a job number to a filename based on the service.
(defn setfname [service filename] (+ (get scriptloc service) filename))

; Get the parallel launcher from a given file.
(defn getparaline[filename]
	(setv r "")
	(try 
		(with [f (open filename)]
			(try
				(for [line f] 
					(if (not (.startswith (.strip line) excludes))
						(if (not (.startswith (.strip line) "module"))
							(do
								(for [d directs]
									(if (in d (.strip line))
										(setv r line)
									)
								)
								(for [l launchers]
									(if (.startswith (.strip line) l)
										(setv r line)
									)
								)
								(if (.startswith (.strip (.upper line)) "EXEC")
									(setv r line))	
								(if (in "mpirun" (.strip line))
									(setv r line))	
								(if (in "mpiexec" (.strip line))
									(setv r line))	
								(if (in "gerun" (.strip line))
									(setv r line))	

							)
						)
					)
				)
				(except [UnicodeDecodeError]
					(do (setv r "")))
			)

		)
		(except [FileNotFoundError] 
			(do (setv r "")))
	)
	r
)

; Check lowercase containment.
(defn isx [line x]
	(if (in (.lower x) (.lower line)))
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
