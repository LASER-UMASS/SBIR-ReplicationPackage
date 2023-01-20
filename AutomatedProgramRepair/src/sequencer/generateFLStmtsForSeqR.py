# the purpose of this script is to generate input file similar to https://github.com/KTH/sequencer/blob/master/src/Defects4J_Experiment/Defects4J_oneLiner_metadata.csv
# that can be used by SequenceR to repair defects. We consider top-10 suspicious statements localized by FL techniques (SBFL, Blues, and SBIR).
# Input: path to the directory storing the FL results 
# Output: Defects4J_oneLiner_metadata.csv file listing suspicious statements of the defects localized out of the 129 single-line-edit defects. 
# cmd to run: python generateFLStmtsForSeqR.py ../../../data/129defects.txt ../../../../FaultLocalization/data/SBFL_results/ ../../../../FaultLocalization/data/src_path/ Defects4J_oneLiner_metadata_SBFL.csv "sbfl"

import os
import sys
import json


defects_file = sys.argv[1] # file listing 129 defects
fl_results = sys.argv[2] # root dir of fl results
src_data_path = sys.argv[3] # path storing the class path of src dir for all defects 
csv_file = sys.argv[4] # output csv file ("Defects4J_oneLiner_metadata_SBFL.csv")
technique = sys.argv[5] # one of "sbfl", "blues", "sbir"

defects = []

f = open(defects_file)
for line in f:
    defects.append(line.strip())
f.close()
print(len(defects))

fout = open(csv_file, "w")

for defect in sorted(defects):
    print("processing defect: ", defect)
    project = defect.split("-")[0]
    bug_id = defect.split("-")[1]
    
    if technique == "sbfl" or technique == "blues":
        fl_result_file = fl_results + "/" + project.lower() + "/" + bug_id + "/stmt-susps_top100-normalized.txt"
    else:
        fl_result_file = fl_results + "/" + project.lower() + "/" + bug_id + "/stmt-susps.txt"
    if not os.path.exists(fl_result_file):
        print("missing ", fl_result_file)
        sys.exit(1)
    f = open(fl_result_file)
    next(f)
    print(fl_result_file)

    path = src_data_path + "/" + project.lower() + "/" + bug_id + ".txt"
    print(path)
    src_path = ""
    if not os.path.exists(path):
        print("Source file missing for defect ", defect)
        sys.exit(1)
    f1 = open(path)
    for line in f1:
        src_path = line.strip()
        break
    if len(src_path) < 2:
        print("Source file looks incorrect for defect ", defect)
        sys.exit(1)
    f1.close()

    if src_path[0] == "/":
        src_path = src_path[1:]

    count = 0
    for line in f:
        count += 1
        #org.jfree.chart.renderer.category.AbstractCategoryItemRenderer#1790,1.0
        stmt = line.split(",")[0]
        suspfile = stmt.split("#")[0].strip()
        lineno = stmt.split("#")[1].strip()
        suspfile = src_path + "/" + suspfile.replace(".", "/") + ".java"
        outstmt = project + "\t" + bug_id + "\t" + suspfile + "\t" + lineno + "\n"
        fout.write(outstmt)
        if count == 10:
            break
fout.close()

