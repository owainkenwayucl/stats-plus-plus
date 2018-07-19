;; Get the largest job cost in the given period.
(defn getmax [service]

    (import simpletemplate)
    (import dbtools)

    (setv keys {"%DB%" (+ service "_sgelogs")})
    (setv query (simpletemplate.templatefile 
                           :filename "sql/get-max-cost.sql"
                           :keys keys))

    (setv data (dbtools.dbquery :db (get keys "%DB%")
                           :query query))
    data
)

(defn getcpubetween [service period minc maxc]

    (import simpletemplate)
    (import dbtools)

    (setv keys {"%DB%" (+ service "_sgelogs") "%PERIOD%" period "%MINCOST%" minc "%MAXCOST%" maxc})
    (setv query (simpletemplate.templatefile 
                           :filename "sql/cputime-by-job-size.sql"
                           :keys keys))

    (setv data (dbtools.dbquery :db (get keys "%DB%")
                           :query query))
    data
    

)

;; This is our main function.
(defmain [&rest args]

    (import dbtools)

    (setv service (get args 1))
    (setv period (get args 2)) ;; the month we are looking at.


    (setv max_cost (get (get (getmax service) 0) "max_cost"))
    

    (setv upper 16)
    (setv lower 0)

    (setv data {})
    (setv names [])

    (while (> max_cost lower)
        (setv name (+ (str (+ 1 lower)) "-" (str upper)))
        (.append names name)
        (assoc data name (getcpubetween service period lower upper))
        (setv lower upper)
        (setv upper (* 2 upper)) 
    )
    (print (+ service "," period))
    (print "Category, CPU_TIME (s)")
    (for [i names]
        (setv t  (dbtools.undecimal (get (get (get data i)0) "cpu_time")))
        (print (+ i ",") t )
    )

    
)