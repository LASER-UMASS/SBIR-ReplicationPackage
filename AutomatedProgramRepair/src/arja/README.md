## Arja


This directory contains customized version of Arja to take pre-computed fault localization (FL) results as input.
The open-source version of Arja is available at https://github.com/yyxhdy/arja.  

**NOTE:** We executed Arja on 689 defects using the process described below with a timeout of 5 hours per defect 
on a 50-node cluster with each node having 128GB of RAM and 200GB of local SSD. Therefore, we do not recommend 
to run Arja on the VM.

To run Arja on pre-computed FL results do:

1. Copy the FL results you want the Arja to "stmt-susps.txt" files in gzoltarFL/<project>/<bugid> directory using the cmd: 
`python copy_fl_results_to_gzoltar.py ../../data/689defects.txt <path-to-FL_results> <path-to-gzoltarFL> <fl technique name ("sbfl", "blues", or "sbir")
(e.g., `python copy_fl_results_to_gzoltar.py ../../../data/689defects.txt ../../../../FaultLocalization/data/SBFL_results/ gzoltarFL sbir`)

2. Create a directory using cmd:
`mkdir work_dir`
 
3. Create an output directory to store produced patches using cmd:
`mkdir arja_patches`

4. Run Arja on a defect using cmd:

`bash runArja.sh <project-in-lowercase> <bugid> <path-to-work_dir> <actual-name-of-the-project> <path-to-gzoltarFL/<project>/<bugid> <path-to-arja_patches>`

e.g., `bash runArja.sh closure 78 /home/sbir/SBIR-ReplicationPackage/AutomatedProgramRepair/src/apr-tools/arja Closure /home/sbir/SBIR-ReplicationPackage/AutomatedProgramRepair/src/apr-tools/arja/fl_results/gzoltarFL/Closure/78/ /home/sbir/SBIR-ReplicationPackage/AutomatedProgramRepair/src/apr-tools/arja/arja_patches`

5. To combine the diff files produced by Arja use the following commands to generate a script that will copy and rename the patches. 

`mkdir arja_patches_diff`

`for i in <path-to-arja_patches>/*/*/Patch*/diff; do j=$(echo $i | cut -d '/' -f 3 | cut -d '_' -f 1,2); k=$(echo $i | cut -d '/' -f 4 | cut -d '_' -f 2); echo "cp $i arja_patches_diff/"$j"_"$k".diff"; done > copyArjaPatches.sh`

`bash copyArjaPatches.sh`

The directory `arja_patches_diff` will store all the patch files in the format `<project>_<bugid>_<variant>.diff` (e.g., `closure_78_301.diff`)
