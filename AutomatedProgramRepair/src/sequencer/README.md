## SequenceR

This directory contains customized version of SequenceR to take pre-computed fault localization (FL) results as input.
The open-source version of SequenceR is available at https://github.com/KTH/sequencer.  

**NOTE:** We executed SequenceR using the process described below on 129 defects with a timeout of 5 hours per defect 
on a 50-node cluster with each node having 128GB of RAM and 200GB of local SSD. Therefore, we do not recommend to 
run SequenceR on the VM.

To run SequenceR on the precomputed FL results do the following. 

1. Clone the SequenceR repository and follow the installation process using Docker as described in [sequencer-GitHub](https://github.com/KTH/sequencer). 

2. Create the FL input (similar to the [Defects4J_oneLiner_metadata.csv](https://github.com/KTH/sequencer/blob/master/src/Defects4J_Experiment/Defects4J_oneLiner_metadata.csv) file) 
using the technique (SBFL, Blues, or SBIR) you want the SequenceR  using the script [`generateFLStmtsForSeqR.py`](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/main/AutomatedProgramRepair/src/apr-tools/sequencer/generateFLStmtsForSeqR.py).
 
e.g., `python generateFLStmtsForSeqR.py ../../../data/129defects.txt ../../../../FaultLocalization/data/SBFL_results/ ../../../../FaultLocalization/data/src_path/ Defects4J_oneLiner_metadata_SBFL.csv "sbfl"` will generate the file [`Defects4J_oneLiner_metadata_SBFL.csv`](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/main/AutomatedProgramRepair/src/apr-tools/sequencer/Defects4J_oneLiner_metadata_SBFL.csv) listing the top-10 suspicious statements for 129 single-line-edit defects localized using SBFL. 

3. Launch SequenceR within the Docker on Defects4J defects following the instructions described under [Defects4J experiment](https://github.com/KTH/sequencer#defects4j-experiment). 

The results are stored in `results/Defects4J_patches` directory. 
