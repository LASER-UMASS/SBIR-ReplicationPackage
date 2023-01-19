## SBFL

To compute SBFL results (implemented using Gzoltar v1.7.2 and Ochiai ranking strategy) do the following.

1. Switch to source directory using cmd: `cd src`
2. Replace `<path-to-SBFL>` with the absolute path of `SBIR-ReplicationPackage/FaultLocalization/src/sbfl` directory in `computeSBFL.sh`
3. To compute SBFL results for a single defect use the cmd 
	`bash computeSBFL.sh <project> <bugid>`  (e.g., `bash computeSBFL.sh Chart 1`).
  The results computed will be stored in `<path-to-SBFL>/sbfl_results` directory.
4. To compute SBFL results for all defects of a project use the cmd: 
	`bash sbfl_<project>.sh`	(e.g., `bash sbfl_chart.sh`).
  The results computed are stored in `<path-to-SBFL>/sbfl_results` directory.
  
NOTE: the precomputed results of all 815 defects are stored in [`SBIR-ReplicationPackage/FaultLocalization/data/SBFL_results`](https://github.com/manishmotwani3/SBIR-ReplicationPackage/tree/main/FaultLocalization/data/SBFL_results) directory.
