## SimFix

This directory contains customized version of SimFix to take pre-computed fault localization (FL) results as input.
The open-source version of SimFix is available at https://github.com/xgdsmileboy/SimFix.  

**NOTE:** We executed SimFix using the process described below on 689 defects with a timeout of 5 hours per defect 
on a 50-node cluster with each node having 128GB of RAM and 200GB of local SSD. Therefore, we do not recommend to 
run SimFix on the VM.

To run SimFix on pre-computed FL results do:

1. Extract the d4j-info.tar.gz and sbfl.tar.gz files using cmd: 
`tar -xvzf <file name>`

2. Copy the FL results you want the SimFix to use to sbfl/ochiai/<project>/<bugid> using cmd: 
`cp ../../../../FaultLocalization/data/SBFL_results/chart/1/stmt-susps_top100-normalized.txt sbfl/ochiai/chart/1/stmt-susps.txt`

3. Create a directory using cmd: 
`mkdir work_dir`
 
4 Create a directory using cmd: 
`mkdir work_dir/chart/`

5. Launch SimFix using the following cmd: 
`bash runSimFix.sh chart 1 work_dir Chart`  

where "chart" is the project name in lower case, "1" is the bugid, and "Chart" is the actual project name used in the Defects4J framework
 
The execution is printed on the termial and the SimFix stores the execution log in `log/<project>/<bugid>.log` file. 
If SimFix patches a defect, the patch is stored in `patch/<project>/<bugid>/` directory which contains the modified source code. 

5. Use the script `getAllPatches.py` to generate diff files from the produced patches. 
