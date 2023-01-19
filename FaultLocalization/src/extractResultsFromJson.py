# the purpose of this script is to extract 
# results of 9 repair tools from release.json
# inputs: path to release.json, output dir
# output: 9 dirs each containing results in
# the form <project>/<bigid>/stmt-susps.txt

import os
import sys
import json

jsonfile = sys.argv[1]
outputdir = sys.argv[2]

if not os.path.isdir(outputdir):
    os.mkdir(outputdir)

f = open(jsonfile)
data = json.load(f)
f.close()

projects = ["chart", "closure", "lang", "math", "time"]
defects = []

for defect in data:
    defects.append(defect)
    for stmt in data[defect]:
        for tool in data[defect][stmt]:
            if tool == 'faulty':
                continue
            tooldirname = tool
            if tool == "slicing":
                tooldirname = "slicing_union"
            elif tool == "slicing_count":
                tooldirname = "slicing_frequency"

            if not os.path.exists(outputdir + "/" + tooldirname):
                os.mkdir(outputdir + "/" + tooldirname)
            for proj in projects:
                if proj in defect:
                    bugid = defect.split(proj)[1]
                    if not os.path.exists(outputdir + "/" + tooldirname + "/" + proj):
                        os.mkdir(outputdir + "/" + tooldirname + "/" + proj)
                    if not os.path.exists(outputdir + "/" + tooldirname + "/" + proj +"/" + bugid):
                        os.mkdir(outputdir + "/" + tooldirname + "/" + proj +"/" + bugid) 
                    
                    outputfile = outputdir + "/" + tooldirname + "/" + proj +"/" + bugid + "/stmt-susps.txt"
                    print(defect, tool, tooldirname, outputfile)
                    f = open(outputfile, "a")
                    score = data[defect][stmt][tool] 
                    outstr = stmt.replace(":", "#") + "," + str(score) + "\n"
                    f.write(outstr)
                    f.close()
print(len(defects))
