# # MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#####################################################################################
# The pupose of this script is to compute the FL performance (in terms of EXAM and hit@k metrics).
# Inputs: 
# 1. path to file containing ground truth (FLGTD4J.csv)
# 2. path to file listing dataset defects (e.g., 815defects.txt)
# 3. path to directory containing localized statements
# 4. Defects4J project (e.g., "chart", "time", "codec", etc. Use "" to consider all projects)
# 5. number of statements to consider (k in top-k). E.g., use one of 1, 25, 50, 100, 10000. Specify 'all' to use all k values. 
# Output: FL results printed on console
# cmd to run: python computeFLperformance.py <path-to FLGTD4J.csv> <path-to fl_results> <project> <k>
# e.g., python computeFLperformance.py FLGTD4J.csv 815defects.txt sbir_stmts "" 100
#####################################################################################

import os
import sys
import re 
import os.path
from collections import OrderedDict

AllDefects = {}
ground_truth_path = sys.argv[1]
dataset_path = sys.argv[2]
fl_results_path = sys.argv[3]
proj = sys.argv[4]
k = sys.argv[5]

class Defect(object):
    def __init__(self, project, bug_id):
         self.project = project
         self.bug_id = bug_id
         self.dev_modifications = {} 
         self.fl_results = {} 

    def storeDeveloperModifiedInformation(self, modified_file, modified_lines):
        distinct_modified_lines = []
        if len(modified_lines) > 0:
            for l in modified_lines:
                distinct_modified_lines.append(int(l))
        self.dev_modifications[modified_file] = distinct_modified_lines

# store defects in dataset
dataset = open(dataset_path) 
dataset_defects = []
for line in dataset:
    dataset_defects.append(line.strip().lower())
dataset.close()

# store ground truth information
ground_truth = open(ground_truth_path)
next(ground_truth)
for line in ground_truth:
    record = line.split(",")
    project = record[0]
    bug_id = record[1]
    defect = project + "-" + bug_id
    
    proj_list = proj.strip().split(',')
    if len(proj) > 0 and project.lower() not in proj_list:
        continue
    
    if defect.lower() not in dataset_defects:
        continue 
    
    d = Defect(project, bug_id)
    if defect not in AllDefects:
        AllDefects[defect] = d
    modified_file = record[2]
    modified_line = record[3].strip()
   # print(defect, modified_file, modified_line)
    if ";" in modified_line:
        modified_lines = modified_line.split(";")
    elif len(modified_line)>0:
        modified_lines = [modified_line]
    AllDefects[defect].storeDeveloperModifiedInformation(modified_file, modified_lines)
ground_truth.close()
print("Dataset Size:", len(AllDefects))

def getSortedFlResults(stmt_path, topk):
    stmt_score = {}
    f = open(stmt_path)
    for line in f:
        if "Statement,Suspiciousness" in line:
            continue
        stmt = line.split(",")[0].strip()
        score = float(line.split(",")[1].strip())
        if score > 0.0:
            stmt_score[stmt] = score
    f.close()
    stmt_score_sorted = {k: v for k, v in sorted(stmt_score.items(), key=lambda item: item[1], reverse=True)}
    ordered_stmt_score = OrderedDict()
    for key in stmt_score_sorted:
        ordered_stmt_score[key] = stmt_score_sorted[key]
    return ordered_stmt_score

def computeFLMetrics(topk):
    sum_exam = 0.0
    localized_defects = []
    for defect in sorted(AllDefects):
        d = AllDefects[defect]
        defect = d.project + "-" + d.bug_id
        localized = False
        total_inspected = 0
        exam = 1.0

        fl_file_path = fl_results_path + "/" + d.project.lower() + "/" + str(d.bug_id ) + "/stmt-susps.txt"
        #print("=>", fl_file_path) 
        if not os.path.exists(fl_file_path):
            continue
        sorted_fl_results = getSortedFlResults(fl_file_path, topk)
        total_statements = len(sorted_fl_results)
        index = 0
        for stmt in sorted_fl_results:
            score = sorted_fl_results[stmt]
            modified_file = stmt.split("#")[0].replace(".", "/") + ".java"
            modified_line = int(stmt.split("#")[1].strip())
            if score > 0.0:
                index += 1
                for fl in d.dev_modifications:
                    if fl.find(modified_file) != -1:  
                        if (modified_line) in d.dev_modifications[fl]:
                            total_inspected += 1
                            localized = True
                            break 
                
                if not localized:
                    total_inspected += 1
                if localized or index == topk:
                    break
        sorted_fl_results.clear()
        if total_inspected == 0.0:
            total_inspected = 1.0

        if topk > 1 and topk < total_statements:
            exam = float(total_inspected)/float(topk)
        else:
            if topk == 1 and localized:
                exam = 0.01
            else:
                if localized:
                    exam = float(total_inspected)/float(total_statements)
                else:
                    exam = 1.0
        if localized:
            sum_exam += exam
            if defect not in localized_defects:
                localized_defects.append(defect)
                #print(defect)
    print("hit@k: ", len(localized_defects), " out of ", len(AllDefects))
    if len(localized_defects) > 0:
        print("Avg EXAM: ", round(float(sum_exam)/float(len(localized_defects)),3))
    else:    
        print("Avg EXAM: NA")

topk = [1, 25, 50, 100, 10000]
if k == 'all':
    for tk in topk:
        print("Computing results for top-" + str(tk))
        computeFLMetrics(tk)
else:
    topk = k.split(",")
    for tk in topk:
        print("Computing results for top-" + tk)
        computeFLMetrics(int(tk))
