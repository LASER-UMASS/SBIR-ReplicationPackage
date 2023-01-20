### SBIR(RAFL) vs SBIR(RankSVM) using CombineFL - An infrastructure for evaluating and combining fault localization techniques.

#### Create annotated dataset for RankSVM

To conduct this analysis, we create dataset of 815 defects annotated with the normalized suspiciousness scores of SBFL and Blues fault localization techniques. To create the annotated dataset, execute the script [generateJson815.py](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/main/FaultLocalization/src/sbir_vs_ranksvm/generateJson815.py) using the command
`python generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../data/blues_results/ ../../data/SBIR_results/sbir_seed1/ ../../data/groundTruthD4J.csv ../../data/src_path/ sbfl_blues_815.json`

The annotated datasets are already available in this repository. 

#### To execute a fresh run of RankSVM 

1. update the path of the annotated dataset (`sbfl_blues_815.json`)(https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/main/FaultLocalization/src/sbir_vs_ranksvm/sbfl_blues_815.json) file in [`1-combine815.py`](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/7e0e3064e2da206398ba8f41ee8e6977fd77f48d/FaultLocalization/src/sbir_vs_ranksvm/1-combine815.py#L6 ).
2. comment out [`sbir`](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/7f16268b3fc562c303e774f4b0ca837479412c6c/FaultLocalization/src/sbir_vs_ranksvm/1-combine815.py#L12) feature in the `1-combine815.py` file.  
3. `rm -rf qid-lines.csv`
4. `python 1-combine815.py`
5. `./2-split.sh`
6. `./3-crossvalidation.sh`   **note: this can take a few hours**
7. `mv qid-lines.csv data`
8. `python 4-calc-metric.py svmrank-pred.data`

#### To evaluate SBIR using CombineFL framework

1. update the path of the annotated dataset (`sbfl_blues_sbir1_815.json`)(https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/main/FaultLocalization/src/sbir_vs_ranksvm/sbfl_blues_sbir1_815.json) file in [`1-combine815.py`](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/7e0e3064e2da206398ba8f41ee8e6977fd77f48d/FaultLocalization/src/sbir_vs_ranksvm/1-combine815.py#L6 ).
2. comment out [`sbfl` and `blues`]([https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/7f16268b3fc562c303e774f4b0ca837479412c6c/FaultLocalization/src/sbir_vs_ranksvm/1-combine815.py#L12](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/blob/7f16268b3fc562c303e774f4b0ca837479412c6c/FaultLocalization/src/sbir_vs_ranksvm/1-combine815.py#L9)) features in the `1-combine815.py` file.  
3. `rm -rf qid-lines.csv`
4. `bash evaluateSBIRUsingCombineFL.sh`

#### To use the pre-trained models and datasets to evaluate the FL performance, execute the following commands.

`bash evaluateRankSVM.sh` to compute the FL performance of using RankSVM to combine SBFL and Blues for the 815 defects in Defects4J~v2.0

`bash evaluateSBIR.sh` to compute the FL performance of using RAFL (executed using 10 random seeds) to combine SBFL and Blues for the 815 defects in Defects4J~v2.0
