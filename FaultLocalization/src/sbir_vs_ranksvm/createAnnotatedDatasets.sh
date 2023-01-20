#!/bin/bash
# The purpose of this script is to generate json files containing 815 defects
# annotated with features to compare RankSVM and RAFL. 

# we first generate a json file annotated with SBFL and Blues scores, which 
# we use to train and test RankSVM. For this, comment out the lines that 
# write SBIR scores in generateJson815.py and then execute the script.

python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed1/ ../../data/groundTruthD4J.csv sbfl_blues_815.json


# Next, we uncomment the lines writing sbir scores and create json files for 
# the 10 SBIR seeds. The generated json files are used to evaluate SBIR using 
# the same cross-validation and E_inspect@k and EXAM metrics provided in the combineFL framework. 

python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed1/ ../../data/groundTruthD4J.csv sbfl_blues_sbir1_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed7/ ../../data/groundTruthD4J.csv sbfl_blues_sbir7_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed47/ ../../data/groundTruthD4J.csv sbfl_blues_sbir47_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed160/ ../../data/groundTruthD4J.csv sbfl_blues_sbir160_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed561/ ../../data/groundTruthD4J.csv sbfl_blues_sbir561_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed630/ ../../data/groundTruthD4J.csv sbfl_blues_sbir630_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed657/ ../../data/groundTruthD4J.csv sbfl_blues_sbir657_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed754/ ../../data/groundTruthD4J.csv sbfl_blues_sbir754_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed828/ ../../data/groundTruthD4J.csv sbfl_blues_sbir828_815.json
python3 generateJson815.py ../../data/815defects.txt ../../data/SBFL_results/ ../../blues_results/ ../../data/SBIR_results/sbir_seed956/ ../../data/groundTruthD4J.csv sbfl_blues_sbir956_815.json
