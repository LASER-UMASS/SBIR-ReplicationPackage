# the purpose of this script is to create an annotated dataset 
# of defect statements annotated with suspiciousness scores of
# different FL techniques that can be used to train supervised
# combining FL techniques such as RankSVM. 
# cmd to run: python generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../data/blues_results/ ../../data/SBIR_results/sbir_seed1/ ../../data/groundTruthD4J.csv ../../data/src_path/ sbfl_blues_815.json

import os
import sys
import json


defects_file = sys.argv[1] # file listing 815 defects
fl_results_sbfl = sys.argv[2] # root dir of sbfl results
fl_results_blues = sys.argv[3] # root dir of blues results
fl_results_sbir = sys.argv[4] # root dir of sbir results
ground_truth_path = sys.argv[5] # ground truth
src_data_path = sys.argv[6] # path storing the class path of src dir for all defects 
add_in_file = sys.argv[7] # output json file ("sbfl_blues_sbir1_815.json")


DefectData = {}
defects = []
defect_defstmts = {}
defstmt_sbfl_score = {}
defstmt_blues_score = {}
defstmt_sbir_score = {}
ground_truth = {}

add_in = "{" + "\n"
fa = open(add_in_file, "a")
fa.write(add_in)

class Defect(object):
    def __init__(self, project, bug_id):
         self.project = project
         self.bug_id = bug_id
         self.dev_modifications = {}
         self.sbfl_results = {}
         self.blues_results = {}
         self.sbir_results = {}
         self.faulty_stmts = []
         self.all_stmts = []
         self.src_path = ""

    def storeDeveloperModifiedInformation(self, modified_file, modified_lines):
        distinct_modified_lines = []
        if len(modified_lines) > 0:
            for l in modified_lines:
                distinct_modified_lines.append(int(l))

        f = modified_file.replace(".java", "")
        f = f.replace(self.src_path[1:], "")
        f = f.replace("/", ".")#[1:]
        if f[0] == ".":
            f = f[1:]
        self.dev_modifications[f] = distinct_modified_lines

    def storeSBFLInformation(self, sbflstmt_scores):
        for stmt in sbflstmt_scores:
            self.sbfl_results[stmt] = sbflstmt_scores[stmt]

    def storeBluesInformation(self, bluesstmt_scores):
        for stmt in bluesstmt_scores:
            self.blues_results[stmt] = bluesstmt_scores[stmt]

    def storeSBIRInformation(self, sbirstmt_scores):
        for stmt in sbirstmt_scores:
            self.sbir_results[stmt] = sbirstmt_scores[stmt]

    def computeAllStatementsAndGT(self):
        for f in self.dev_modifications:
            lines = self.dev_modifications[f]
            for l in lines:
                stmt = f + ":" + str(l)
                faulty = 1
                if stmt not in self.faulty_stmts:
                    self.faulty_stmts.append(stmt)
        for s in self.sbfl_results:
            if s not in self.all_stmts:
                self.all_stmts.append(s)
        for s in self.blues_results:
            if s not in self.all_stmts:
                self.all_stmts.append(s)
        # UNCOMMENT BELOW CODE FOR GENERATING DATASETS CONTAINING SBIR SCORES
        #for s in self.sbir_results:
        #    if s not in self.all_stmts:
                #self.all_stmts.append(s)
        for s in self.faulty_stmts:
            if s not in self.all_stmts:
                self.all_stmts.append(s)

    def setSrcPath(self, src_path):
        path = src_path + "/" + self.project.lower() + "/" + self.bug_id + ".txt"
        print(path)
        if not os.path.exists(path):
            print("Source file missing for defect ", self.project.lower() + "-" + self.bug_id)
            sys.exit(1)
        f = open(path)
        for line in f:
            self.src_path = line.strip()
            break
        if len(self.src_path) < 2:
            print("Source file looks incorrect for defect ", self.project.lower() + "-" + self.bug_id)
            sys.exit(1)
        f.close()

f = open(defects_file)
for line in f:
    defects.append(line.strip())
f.close()
print(len(defects))

# store ground truth information
ground_truth = open(ground_truth_path)
next(ground_truth)
for line in ground_truth:
    record = line.split(",")
    project = record[0]
    bug_id = record[1]
    defect = project + "-" + bug_id
    
    if defect not in defects:
        continue

    if defect == "Closure-93" or defect == "Time-21" or defect == "JacksonDatabind-58" or defect == "Lang-2" or defect == "Time-5":
            continue    
    
    d = Defect(project, bug_id)
    d.setSrcPath(src_data_path)
    
    modified_file = record[2]
    modified_line = record[3].strip()

    if defect not in DefectData:
        DefectData[defect] = d
    if len(modified_line) > 0:
        modified_lines = modified_line.split(";")
        DefectData[defect].storeDeveloperModifiedInformation(modified_file, modified_lines)
    else:
    	modified_line = ""
    
ground_truth.close()
print(len(DefectData))
####
# store FL results

numdefects = len(DefectData)
indexdefect = 0
for defect in sorted(DefectData):
    print("processing defect: ", defect)
    project = defect.split("-")[0]
    bug_id = defect.split("-")[1]

    # store SBFL resuls
    print("storing SBFL results")
    sbflstmt_scores = {}
    sbfl_result_file = fl_results_sbfl + "/" + project.lower() + "/" + bug_id + "/stmt-susps-normalized.txt"
    if not os.path.exists(sbfl_result_file):
        print("missing ", sbfl_result_file)
        sys.exit(1)
    f = open(sbfl_result_file)
    next(f)
    print(sbfl_result_file)
    for line in f:
        if "Statement,Suspiciousness" in line:
            continue
        stmt = line.split(",")[0].strip().replace("#", ":")
        score = float(line.split(",")[1].strip())
        if stmt not in sbflstmt_scores:  
            sbflstmt_scores[stmt] = score
        else:                            # the stmt has been seen before 
            if sbflstmt_scores[stmt] < score:    # update susp score if new score is higher
                sbflstmt_scores[stmt] = score
    f.close()
    DefectData[defect].storeSBFLInformation(sbflstmt_scores)
    sbflstmt_scores.clear() 

    # store Blues resuls
    print("storing Blues results")
    bluesstmt_scores = {}
    blues_result_file = fl_results_blues + "/" + project.lower() + "/" + bug_id + "/stmt-susps-normalized.txt"
    print(blues_result_file)
    if not os.path.exists(blues_result_file):
        print("missing ", blues_result_file)
        sys.exit(1)
    f = open(blues_result_file)
    for line in f:
        if "Statement,Suspiciousness" in line:
            continue
        stmt = line.split(",")[0].strip().replace("#", ":")
        score = float(line.split(",")[1].strip())
        if stmt not in bluesstmt_scores:  
            bluesstmt_scores[stmt] = score
        else:                            # the stmt has been seen before 
            if bluesstmt_scores[stmt] < score:    # update susp score if new score is higher
                bluesstmt_scores[stmt] = score
    f.close()
    
    DefectData[defect].storeBluesInformation(bluesstmt_scores)
    bluesstmt_scores.clear()

    # store SBIR resuls
    print("storing SBIR results")
    sbirstmt_scores = {}
    sbir_result_file = fl_results_sbir + "/" + project.lower() + "/" + bug_id + "/stmt-susps.txt"
    print(sbir_result_file)
    if not os.path.exists(sbir_result_file):
        print("missing ", sbir_result_file)
        sys.exit(1)
    f = open(sbir_result_file)
    for line in f:
        if "Statement,Suspiciousness" in line:
            continue
        stmt = line.split(",")[0].strip().replace("#", ":")
        score = float(line.split(",")[1].strip())
        if stmt not in sbirstmt_scores:  
            sbirstmt_scores[stmt] = score
        else:                                     # the stmt has been seen before 
            if sbirstmt_scores[stmt] < score:    # update susp score if new score is higher
                sbirstmt_scores[stmt] = score
    f.close()
    DefectData[defect].storeSBIRInformation(sbirstmt_scores)
    sbirstmt_scores.clear()
    DefectData[defect].computeAllStatementsAndGT()

    add_in = "\"" + project + bug_id + "\": {" + "\n"
    #print("writing-> ", add_in)
    fa.write(add_in)
    
    numstmts = len(DefectData[defect].all_stmts)
    index = 0
    foundFaulty = False
    for stmt in DefectData[defect].all_stmts:
        sbfl_score = 0.0
        blues_score = 0.0
        #sbir_score = 0.0
        faulty = 0
        if stmt in DefectData[defect].sbfl_results:
            sbfl_score = DefectData[defect].sbfl_results[stmt] 
        if stmt in DefectData[defect].blues_results:
            blues_score = DefectData[defect].blues_results[stmt] 
        # UNCOMMENT BELOW LINES FOR GENERATING DATASETS CONTAINING SBIR SCORES
        #if stmt in DefectData[defect].sbir_results:
        #    sbir_score = DefectData[defect].sbir_results[stmt] 
        if stmt in DefectData[defect].faulty_stmts:
            faulty = 1
            foundFaulty = True
        add_in = "\"" + stmt + "\": {" + "\n"
        fa.write(add_in)
        add_in = "\"" + "sbfl" + "\": " + str(sbfl_score) + ",\n"
        fa.write(add_in)
        add_in = "\"" + "blues" + "\": " + str(blues_score) + ",\n"
        fa.write(add_in) 
        # UNCOMMENT BELOW LINES FOR GENERATING DATASETS CONTAINING SBIR SCORES
        #add_in = "\"" + "sbir" + "\": " + str(sbir_score) + ",\n"
        #fa.write(add_in)
        add_in = "\"" + "faulty" + "\":" + str(faulty)
        fa.write(add_in)
        index += 1
        if index < numstmts:    
            add_in = "},\n"
            fa.write(add_in)
        else:
            add_in = "}\n"
            fa.write(add_in)
    indexdefect += 1
    if indexdefect < numdefects:    
        add_in = "},\n"
        fa.write(add_in)
    else:
        add_in = "}\n"
        fa.write(add_in)
    if foundFaulty == False:
        print(defect, " has no faulty stmt!!")
        sys.exit(1)
    
    print("done with", defect)
    print("####################")
add_in = "}"
fa.write(add_in)
fa.close()
print("Total Defects Annotated:", indexdefect)
"""
######################################
# below code is to pretty print json
######################################
# using following cmd to remove nulls 
# tr < sbfl_blues_sbir1_815.json -d '\000' > sbfl_blues_sbir1_815_temp.json
add_in_file = "sbfl_blues_sbir1_815_temp.json"
f = open(add_in_file)
new_data = json.load(f)
f.close()

final_output_file = "sbfl_blues_sbir1_815_final.json"
f = open(final_output_file, "w")
json.dump(new_data, f, indent=4)
f.close()

sys.exit(0)
####################################
####################################
#"""

