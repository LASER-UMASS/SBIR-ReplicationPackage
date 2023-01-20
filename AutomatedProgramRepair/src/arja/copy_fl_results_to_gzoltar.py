# The purpose of this script is to copy the FL results file (stmt-susp.txt) 
# to the relevant GZoltar directory so that arja can access the FL results 
# as well as relevant positive and negative tests of a defect.
# inputs: file listing defects, path to src, path to dest
# output: none (files in dest get replaced with files in src)
# e.g. cmd to run: python copy_fl_results_to_gzoltar.py ../../../data/689defects.txt ../../../../FaultLocalization/data/SBFL_results/ gzoltarFL sbfl

import sys
import os

defectfile = open(sys.argv[1])               # /home/manish/SBIR-ReplicationPackage/AutomatedProgramRepair/data/689defects.txt
src_dir = sys.argv[2]                        # /home/manish/SBIR-ReplicationPackage/FaultLocalization/data/SBIR_results/sbir_seed1
dest_dir = sys.argv[3]                       # /home/manish/SBIR-ReplicationPackage/AutomatedProgramRepair/src/apr-tools/arja/gzoltarFL 
technique = sys.argv[4]                     # "sbir", "sbfl", or "blues"
count = 1


if technique == "sbir":
    for line in defectfile:
        record = line.split("-")
        project = record[0].lower()
        buigid = record[1].strip()
        if "jackson" in project:
            prefix = "jackson"
            suffix = project.split("jackson")[1].strip()
            cmd = "cp " +  src_dir.strip() + "/" + project + "/" + buigid + "/stmt-susps.txt " + dest_dir.strip() + "/" + prefix.capitalize() + suffix.capitalize() + "/" + buigid + "/stmt-susps.txt"
        elif "jxpath" in project:
            cmd = "cp " +  src_dir.strip() + "/" + project + "/" + buigid + "/stmt-susps.txt " + dest_dir.strip() + "/JxPath/" + buigid + "/stmt-susps.txt" 
        else:
            cmd = "cp " +  src_dir.strip() + "/" + project + "/" + buigid + "/stmt-susps.txt " + dest_dir.strip() + "/" + project.capitalize() + "/" + buigid + "/stmt-susps.txt"
        print(str(count) + ": " + project + "-" + buigid)
        count += 1
        os.system(cmd)
else:
    for line in defectfile:
        record = line.split("-")
        project = record[0].lower()
        buigid = record[1].strip()
        if "jackson" in project:
            prefix = "jackson"
            suffix = project.split("jackson")[1].strip()
            cmd = "cp " +  src_dir.strip() + "/" + project + "/" + buigid + "/stmt-susps_top100-normalized.txt " + dest_dir.strip() + "/" + prefix.capitalize() + suffix.capitalize() + "/" + buigid + "/stmt-susps.txt"
        elif "jxpath" in project:
            cmd = "cp " +  src_dir.strip() + "/" + project + "/" + buigid + "/stmt-susps_top100-normalized.txt " + dest_dir.strip() + "/JxPath/" + buigid + "/stmt-susps.txt" 
        else:
            cmd = "cp " +  src_dir.strip() + "/" + project + "/" + buigid + "/stmt-susps_top100-normalized.txt " + dest_dir.strip() + "/" + project.capitalize() + "/" + buigid + "/stmt-susps.txt"
        print(str(count) + ": " + project + "-" + buigid)
        count += 1
        os.system(cmd)
