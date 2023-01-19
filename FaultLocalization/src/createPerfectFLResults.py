#the purpose of this script is to create 
#perfect FL files to run repair tools and
# obtain upper bound performance
# cmd to run: python createPerfectFLResults.py ../data/815defects.txt ../data/groundTruthD4J.csv ../data/perfectFL_results ../data/src_path/ 

import sys
import os

defects_file = sys.argv[1]          # file listing 815 defects (../data/815defects.txt)
ground_truth_path = sys.argv[2]     # path to ground truth file (../data/groundTruthD4J.csv) 
output_dir = sys.argv[3]           # path to store the results (../data/perfectFL_results/)
src_path_dir = sys.argv[4]          # path to dir storing paths to src dir of all defects (../data/src_path/)

defects = []

def getSrcPath(project, bug_id, src_path):
    path = src_path + "/" + project.lower() + "/" + bug_id + ".txt"
    #print(path)
    if not os.path.exists(path):
        print("Source file missing for defect ", project.lower() + "-" + bug_id)
        sys.exit(1)
    f = open(path)
    for line in f:
        return line.strip()
    if len(self.src_path) < 2:
        print("Source file looks incorrect for defect ", project.lower() + "-" + bug_id)
        sys.exit(1)
    f.close()


f = open(defects_file)
for line in f:
    defects.append(line.strip())
f.close()
print(len(defects))


ground_truth = open(ground_truth_path)
next(ground_truth)
for line in ground_truth:
    record = line.split(",")
    project = record[0]
    bug_id = record[1]
    defect = project + "-" + bug_id
    
    print(len(defects))
    matched = False
    for d in defects:
        print("=>", d)
        if defect == d:
            matched = True
            print(defect, d)
    if not matched:
        continue

    # skip defects that are not localized by SBFL or Blues
    if defect == "Closure-93" or defect == "Time-21" or defect == "JacksonDatabind-58" or defect == "Lang-2" or defect == "Time-5":
        continue

    print(defect)
    modified_file = record[2]
    mf = modified_file.replace(".java", "")
    sp = getSrcPath(project, bug_id, src_path_dir)
    #print(sp, mf)
    mf = mf.replace(sp[1:], "")
    #print(mf)
    mf = mf.replace("/", ".")[1:]
    
    modified_line = record[3].strip()
    if len(modified_line) > 0:
        modified_lines = modified_line.split(";")
    else:
        modified_lines = []

    if not os.path.isdir(output_dir):
        os.mkdir(output_dir)
    if not os.path.isdir(output_dir + "/" + project.lower()):
        os.mkdir(output_dir + "/" + project.lower())
    if not os.path.isdir(output_dir + "/" + project.lower() + "/" + bug_id):
        os.mkdir(output_dir + "/" + project.lower() + "/" + bug_id)

    flag = True
    output_file = output_dir + "/" + project.lower() + "/" + bug_id + "/stmt-susps.txt"
    if os.path.exists(output_file):
        flag = False
    f = open(output_file, "a")
    if flag:
        f.write("Statement,Suspiciousness\n")
    for l in modified_lines:
        outstr = mf + "#" + l + ",1.0\n"
        print(project + "," + bug_id + "," + mf + "," + l)
        f.write(outstr)
    f.close()
    if defect == "Closure-13":
        print(defects)
        print(defect in defects)
        break
