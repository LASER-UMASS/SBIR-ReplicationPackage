# the purpose of this script is to process 
# the statement level results of iFixR 
# and store them in a format Statement, Suspiciousness
# e.g., org.jfree.chart.renderer.category.AbstractCategoryItemRenderer#1790,1.0 for Chart 1
# cmd to run: python formatiFixRresults.py ../data/iFixR_defects.txt ../data/stmtLoc/


import sys
import os
from pathlib import Path

ifixr_defects = sys.argv[1] # path to file listing defects localized by iFixR
fl_results = sys.argv[2]  # path to dir containing fl results file of iFixR
output_dir = sys.argv[3]  # path to dir storing the formatted results
defects = []

f = open(ifixr_defects)
for line in f:
    defects.append(line.strip())
f.close()

def formatResults(ifix_result_file, project, bug):
    output_file_dir = output_dir + "/" + project.lower() + "/" + bug
    Path(output_file_dir).mkdir(parents=True, exist_ok=True)
    o = open(output_file_dir + "/stmt-susps.txt", "w")
    o.write("Statement,Suspiciousness\n")
    f = open(ifix_result_file)
    next(f)
    for line in f:
        record = line.split(",")
        classname = record[2].strip().replace(".java", "").replace("/", ".").replace("src.main.java.","")
        score = float(record[3].strip())
        if score <= 0.0:
            continue
        print(line)
        linenums = record[4].strip()
        if len(linenums) <= 0:
            continue
        if "," in linenums:
            linenos_list = linenums.split(",")
            for linenos in linenos_list:
                startlineno = linenums.split("-")[0].replace("\'","").replace("\"", "").replace("[", "").strip()
                endlineno = linenums.split("-")[1].replace("\'","").replace("\"", "").replace("]","").strip()
                for i in range(int(startlineno), int(endlineno) + 1):
                    output_text = classname + "#" + str(i) + "," + str(score) + "\n"
                    o.write(output_text)
        else:
            startlineno = linenums.split("-")[0].replace("\'","").replace("\"", "").replace("[", "").strip()
            endlineno = linenums.split("-")[1].replace("\'","").replace("\"", "").replace("]","").strip()
            for i in range(int(startlineno), int(endlineno) + 1):
                output_text = classname + "#" + str(i) + "," + str(score) + "\n"
                o.write(output_text)

    f.close()
    o.close()

for defect in defects:
    print(defect)
    record = defect.split("_")
    project = record[0]
    bugno = record[1]
    file_path = fl_results + "/" + defect
    formatResults(file_path, project, bugno)

