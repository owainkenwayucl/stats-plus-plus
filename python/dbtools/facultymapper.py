'''
   This library reads in a mapping of faculties -> departments from a csv file.
'''

def getmap(filename="reference/facultymap.csv"):
    import csv

    faculties={}

    with open(filename) as csvfile:
        facultyreader = csv.reader(csvfile, delimiter='|', quotechar='"')
        for row in facultyreader:
            if len(row) > 0:
                f = row[1]
                d = row[0]
                if f in faculties.keys():
                    faculties[f].append(d)
                else:
                    faculties[f]=[]
                    faculties[f].append(d)


    return faculties