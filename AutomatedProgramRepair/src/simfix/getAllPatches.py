# The purpose of this script is to generate diff files 
# from the patches produced by SimFix. 
# Input: path to the "patch" folder output by SimFix
# Output: directory "simfix_patches" that stores all 
# the diff files in the format: <project><bugid>_<variant>.diff
# e.g., cmd to run: python getAllPatches.py patch/

import os
import sys
import subprocess

patchedFilesPath = sys.argv[1]

files = []
# r=root, d=directories, f = files
for r, d, f in os.walk(patchedFilesPath):
        for file in f:
                if '.java' in file:
                        files.append(os.path.join(r, file))

greppattern = {}

greppattern['time'] = "main/java/org/"
greppattern['lang'] = "java/org/"
greppattern['jxpath'] = "java/org/"
greppattern['math'] = "java/org/"
greppattern['cli'] = "java/org/"
greppattern['codec'] = "java/org/"
greppattern['collections'] = "main/java/org/"
greppattern['compress'] = "main/java/org/"
greppattern['gson'] = "main/java/com"
greppattern['jacksoncore'] = "main/java/com"
greppattern['jacksondatabind'] = "main/java/com"
greppattern['jsoup'] = "main/java/org"
greppattern['csv'] = "main/java/org/"
greppattern['chart'] = "buggy/source/"
greppattern['closure'] = "buggy/src/"
greppattern['mockito'] = "buggy/src/"


for f in sorted(files):
        record = f.split("/") # ['patch', 'chart', '3', '0', '1_TimeSeries.java']
        folder = record[0]
        project = record[1]
        bugid = record[2]
        variant = record[3]
        patchedfilename = str(record[4])
        print(project, bugid, patchedfilename)
        filename = patchedfilename.split("_")[1].strip()
        command = "find \"work_dir/" + project + "/" + project + "_" + bugid + "_buggy/\" -name " + filename + " | grep " + "\"" + greppattern[project] + "\""
        output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        original_file = str(output.stdout.read().strip().decode("utf-8"))
        print(original_file)
        if project=="closure":
                if bugid == "80":
                        original_file = "work_dir/closure/closure_80_buggy/src/com/google/javascript/jscomp/NodeUtil.java"
                elif bugid == "84":
                        original_file = "work_dir/closure/closure_84_buggy/src/com/google/javascript/jscomp/testing/TestErrorReporter.java"
        elif project=="lang":
                if bugid == "44":
                        original_file = "work_dir/lang/lang_44_buggy/src/java/org/apache/commons/lang/NumberUtils.java"
                elif bugid == "58":
                        original_file = "work_dir/lang/lang_58_buggy/src/java/org/apache/commons/lang/math/NumberUtils.java"
        elif project=="math":
                if bugid == "6":
                        original_file = "work_dir/math/math_6_buggy/src/main/java/org/apache/commons/math3/optim/BaseOptimizer.java"
        patched_file = f
        diffcmd = "diff -uwb " + str(original_file) + " " + str(patched_file) + " > simfix_patches/" + str(project) + str(bugid) + "_" + str(variant) + ".diff"       
        print(diffcmd)
        output = subprocess.Popen(diffcmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("\n\n####################################################")
        print(project, bugid, variant)
        print(original_file)
        print(patched_file)
        print(command)
        print(diffcmd)
        print("DIFF OUT:" + output.stdout.read().strip().decode("utf-8"))
        differror = output.stderr.read().strip().decode("utf-8")
        if len(differror) > 0:
                print("DIFF ERROR: " + differror) 
                break
        print("########################################################")
