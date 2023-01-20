#!/bin/bash

# The purpose of this script is to evaluate RankSVM trained by combining SBFL and Blues using the combineFL framework.
# The folders data/cross_data_ranksvm stores the precomputed RankSVM results. 

printf "SBIR(RankSVM)\n"
cp data/qid-lines-ranksvm.csv data/qid-lines.csv 
mv data/cross_data_ranksvm data/cross_data
printf "python2 4-calc-metric.py svmrank-pred.dat\n"
python2 4-calc-metric.py svmrank-pred.dat
mv data/cross_data data/cross_data_ranksvm

rm data/qid-lines.csv

