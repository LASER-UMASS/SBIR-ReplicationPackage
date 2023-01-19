## RAFL

This directory contains executable code for Rank Aggregation-based Fault Localization (RAFL) that implements SBIR, an unsupervised technique to combine results of multiple fault localization techniques, to replicate published results. To re-configure RAFL settings please see the source code available at https://github.com/LASER-UMASS/RAFL.  

### Dependencies:
- `Java` version version 1.8 (https://www.oracle.com/java/technologies/downloads/#java8)
- `R` version version 4.1 (https://cran.r-project.org/)
- `RankAggreg` R package version 0.6.6 (https://cran.r-project.org/web/packages/RankAggreg/index.html)
- `rJava` R package version 1.0-5 (https://cran.r-project.org/web/packages/rJava/index.html)
  (Note: this may require running the following commands before installing `rJava` package in `R`)
   - `export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server:$LD_LIBRARY_PATH`
   - `sudo R CMD javareconf` 
- `Defects4J` version 2.0.0 (https://github.com/rjust/defects4j) 


### Before running the main program do the following:
1. Specify the path of the `SBIR_results` in the directory as the `root_directory` in the `rafl.settings` file. 
2. Set `JAVA_HOME` to point to Java installation directory (e.g., `export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/`)
3. Set `R_HOME` to point to R installation directory (e.g., `export R_HOME=/usr/lib/R/`)
4. Add JRI native library (available inside the directory where rJava is installed) to the default Java Library Path (depends on OS):

On Windows, it maps to `PATH`

On Linux, it maps to `LD_LIBRARY_PATH`

On OS X, it maps to `DYLD_LIBRARY_PATH` 

(e.g., `export LD_LIBRARY_PATH=<path-to>/R/x86_64-pc-linux-gnu-library/4.1/rJava/jri:$LD_LIBRARY_PATH`) 


### RAFL accepts the following command line arguments:

1. `Defect <String>` (e.g., "Chart_1" (to run RAFL on a particular Defects4J defect) or "all" (to run RAFL on all Defects4J defects))
2. `NumOfFlTechniques <Integer>` (the number of FL techniques' results to be combined. This value should be at least 2)
Based on the value specified, the subsequent arguments must specify the path to the files that store the FL results. For example, when combining SBFL and IRFL techniques, the next two arguments will specify: 
3. `Path <String>` to SBFL results (e.g., ../../data/SBFL_results/chart/1/stmt-susps.txt)
4. `Path <String>` to IRFL results (e.g., ../../blues_results/chart/1/stmt-susps.txt)
5. `seed`
6. `sample size (N)` (use 10000 for SBIR)

### To run RAFL on a single defect in Defects4J, use the command:

`java -Djava.library.path=.:<path-to>/R/x86_64-pc-linux-gnu-library/4.1/rJava/jri -jar rafl.jar Chart_1 2 <path-to>/blues_results/chart/1/stmt-susps.txt <path-to>/sbfl_results/chart/1/stmt-susps.txt 1 10000`

The output is stored in `SBIR_results` directory. The output contains intermediate results under `SBIR_results/R_scripts_seed<n>/` directory
and the localized statements under `SBIR_results/sbir_seed<n>` directory. 
For example, when executing SBIR for Chart 1 using seed 1, the localized statements will be stored in `SBIR_results/sbir_seed1/chart/1/stmt-susps.txt` file,
the R script used to compute results will be stored in `SBIR_results/R_scripts_seed1/Chart_1.R` file, and the output log is stored in `SBIR_results/R_scripts_seed1/Chart_1.out` file. 

NOTE: The precomputed results for 815 defects in Defects4J-v2.0 using 10 random seeds are available in [`SBIR-ReplicationPackage/FaultLocalization/data/SBIR_results`](https://github.com/manishmotwani3/SBIR-ReplicationPackage/tree/main/FaultLocalization/data/SBIR_results) directory.  

