# the purpose of this script is to combine blues configuration results and create ensemble.
# cmd to run: python combineBluesUsingMaxScoreConsensus.py ../../data/815defects.txt ../../data/blues_configuration_results/ ../../data/blues_results/

import os
import sys
from collections import OrderedDict

defects_file = sys.argv[1] # file listing 815 defects
root_path = sys.argv[2] # root dir of blues configuration results
output_dir = sys.argv[3] # dir to store combined results 

defects = []

f = open(defects_file)
for line in f:
    defect = line.strip()
    defects.append(defect)

f.close()

defect_defstmts = {}
defstmt_score = {}
defstmt_count = {}

dirs = ["blues_m1_stmts", "blues_m25_stmts", "blues_m50_stmts", "blues_m100_stmts", "blues_mAll_stmts", "blues_mWted_stmts"]

# normalize scores in the list before comparing
def normalizeScores(input_file):
    output_file = input_file.replace(".txt", "-normalized.txt")
    stmt_score = {}
    f = open(input_file)
    next(f)
    for line in f:
        stmt = line.split(",")[0].strip()
        score = float(line.split(",")[1].strip())
        if score > 0.0:
            stmt_score[stmt] = score
    f.close()
    stmt_score_sorted = {k: v for k, v in sorted(stmt_score.items(), key=lambda item: item[1], reverse=True)}
    ordered_stmt_score = OrderedDict()
    for key in stmt_score_sorted:
        ordered_stmt_score[key] = stmt_score_sorted[key]
    f = open(output_file, "w")
    f.write("Statement,Suspiciousness\n")
    total_stmts = len(stmt_score)
    score = 1.0
    decrement = decrement = 1.0/float(total_stmts)
    for s in ordered_stmt_score:
        output = s + "," + str(score) + "\n"
        f.write(output)
        score = score - decrement
    f.close()

# break ties based on list count (vote)
def sortListsByVotes(stmts):
    output = []
    while len(output)!=len(stmts):
        maxVote = 0
        maxStmt = None
        for s in stmts:
            if defstmt_count[s] > maxVote and s not in output:
                maxVote = defstmt_count[s]
                maxStmt = s
        output.append(maxStmt)
    return output


# method to get the fl results sorted based on suspiciousness scores
def getSortedFlResults(d):
    dstmt_score = {}
    for defstmt in defstmt_score:
        score = float(defstmt_score[defstmt]) #/float(defstmt_count[defstmt])
        dstmt_score[defstmt] = score

    dstmt_score_sorted = {k: v for k, v in sorted(dstmt_score.items(), key=lambda item: item[1], reverse=True)}
    ordered_dstmt_score = OrderedDict()
    for key in dstmt_score_sorted:
        ordered_dstmt_score[key] = dstmt_score_sorted[key]
    
    score_dstmts = {}
    for dstmt in ordered_dstmt_score:
        s_score = ordered_dstmt_score[dstmt]
        s_count = defstmt_count[dstmt]
        if s_score not in score_dstmts:
            score_dstmts[s_score] = [dstmt]
        else:
            score_dstmts[s_score].append(dstmt)
    
    output_dstmts_score = []
    for score in reversed(sorted(score_dstmts)):
        s_list = score_dstmts[score]
        sorted_lists_by_vote = sortListsByVotes(s_list)
        for s in sorted_lists_by_vote:
            output_dstmts_score.append(s + "," + str(score))
            #print("==>", s, score, defstmt_count[s])
    return output_dstmts_score

if not os.path.isdir(output_dir):
    os.mkdir(output_dir)

for d in defects:
    defect_defstmts.clear()
    defstmt_score.clear()
    defstmt_count.clear()
    project = d.split("-")[0].lower()
    bug_id = d.split("-")[1].strip()
    print("combining results for " + d)
    result_file = output_dir + "/" + project + "/" + bug_id + "/stmt-susps_top100.txt"
    if os.path.exists(result_file):
        print("result already exists for ", d)
        continue

    for dr in dirs:
        defect_result_path = root_path + "/" + dr + "/" + project + "/" + bug_id
        if os.path.isdir(defect_result_path):
            orig_result_file = defect_result_path + "/stmt-susps.txt"
            normalizeScores(orig_result_file)    
            result_file = defect_result_path + "/stmt-susps-normalized.txt"
            f = open(result_file)
            next(f)
            index = 1
            for line in f:
                stmt = line.split(",")[0].strip().replace("#", ":")
                score = float(line.split(",")[1].strip())
                defstmt = d + "::" + stmt
                if d in defect_defstmts:
                    if defstmt not in defect_defstmts[d]:     # the stmt is seen for the first time
                        defect_defstmts[d].append(defstmt)    # append stmt to the susp list
                        defstmt_score[defstmt] = score        # store the susp score
                        defstmt_count[defstmt] = 1            # store the count
                    else:                                     # the stmt has been seen before 
                        if score > defstmt_score[defstmt]:
                            defstmt_score[defstmt] = score          # update score
                        defstmt_count[defstmt] += 1                                 # add count
                else:                                               
                    defect_defstmts[d] = [defstmt]        # store susp stmt
                    defstmt_score[defstmt] = score        # store the susp score
                    defstmt_count[defstmt] = 1            # store the count
                index += 1
            f.close()
   
    if not os.path.isdir(output_dir + "/" + project):
        os.mkdir(output_dir + "/" + project)
    if not os.path.isdir(output_dir + "/" + project + "/" + bug_id):
        os.mkdir(output_dir + "/" + project + "/" + bug_id)

    if d in defect_defstmts:
        fl_results = getSortedFlResults(d)
        numstmts = len(fl_results)
        output_file = output_dir + "/" + project + "/" + bug_id + "/stmt-susps_top100.txt"
        f = open(output_file, "w")
        f.write("Statement,Suspiciousness\n")
        index = 0
        for dstmtscore in fl_results:
            stmtscore = dstmtscore.split("::")[1].strip()
            index += 1
            output = stmtscore + "\n" 
            f.write(output.replace(":", "#"))
            if index == 100:    # to produce top-100 results
                break
        f.close()
        normalizeScores(output_file)
    print("finished combining")
    
