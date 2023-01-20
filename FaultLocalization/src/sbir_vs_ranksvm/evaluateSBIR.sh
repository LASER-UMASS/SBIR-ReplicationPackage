#!/bin/bash

# The purpose of this script is to evaluate SBIR (RAFL) (10 seeds) 
# using the pre-trained model and data with help of the combineFL framework. 

printf "SBIR (RAFL) SEED-1\n"
mv data/cross_data_sbir1 data/cross_data
cp data/qid-lines-sbir1.csv data/qid-lines.csv 
printf "python2 4-calc-metric.py sbir1-pred.dat\n"
python2 4-calc-metric.py sbir1-pred.dat
mv data/cross_data data/cross_data_sbir1

printf "\n"
printf "SBIR (RAFL) SEED-7\n"
mv data/cross_data_sbir7 data/cross_data
cp data/qid-lines-sbir7.csv data/qid-lines.csv 
printf "python2 4-calc-metric.py sbir7-pred.dat\n"
python2 4-calc-metric.py sbir7-pred.dat
mv data/cross_data data/cross_data_sbir7

printf "\n"
printf "SBIR (RAFL) SEED-47\n"
mv data/cross_data_sbir47 data/cross_data
cp data/qid-lines-sbir47.csv data/qid-lines.csv 
printf "python2 4-calc-metric.py sbir47-pred.dat\n"
python2 4-calc-metric.py sbir47-pred.dat
mv data/cross_data data/cross_data_sbir47

printf "\n"
printf "SBIR (RAFL) SEED-160\n"
cp data/qid-lines-sbir160.csv data/qid-lines.csv 
mv data/cross_data_sbir160 data/cross_data
printf "python2 4-calc-metric.py sbir160-pred.dat\n"
python2 4-calc-metric.py sbir160-pred.dat
mv data/cross_data data/cross_data_sbir160

printf "\n"
printf "SBIR (RAFL) SEED-561\n"
cp data/qid-lines-sbir561.csv data/qid-lines.csv 
mv data/cross_data_sbir561 data/cross_data
printf "python2 4-calc-metric.py sbir561-pred.dat\n"
python2 4-calc-metric.py sbir561-pred.dat
mv data/cross_data data/cross_data_sbir561

printf "\n"
printf "SBIR (RAFL) SEED-630\n"
cp data/qid-lines-sbir630.csv data/qid-lines.csv 
mv data/cross_data_sbir630 data/cross_data
printf "python2 4-calc-metric.py sbir630-pred.dat\n"
python2 4-calc-metric.py sbir630-pred.dat
mv data/cross_data data/cross_data_sbir630

printf "\n"
printf "SBIR (RAFL) SEED-657\n"
cp data/qid-lines-sbir657.csv data/qid-lines.csv 
mv data/cross_data_sbir657 data/cross_data
printf "python2 4-calc-metric.py sbir657-pred.dat\n"
python2 4-calc-metric.py sbir657-pred.dat
mv data/cross_data data/cross_data_sbir657

printf "\n"
printf "SBIR (RAFL) SEED-754\n"
cp data/qid-lines-sbir754.csv data/qid-lines.csv 
mv data/cross_data_sbir754 data/cross_data
printf "python2 4-calc-metric.py sbir754-pred.dat\n"
python2 4-calc-metric.py sbir754-pred.dat
mv data/cross_data data/cross_data_sbir754

printf "\n"
printf "SBIR (RAFL) SEED-828\n"
cp data/qid-lines-sbir828.csv data/qid-lines.csv 
mv data/cross_data_sbir828 data/cross_data
printf "python2 4-calc-metric.py sbir828-pred.dat\n"
python2 4-calc-metric.py sbir828-pred.dat
mv data/cross_data data/cross_data_sbir828

printf "\n"
printf "SBIR (RAFL) SEED-956\n"
cp data/qid-lines-sbir956.csv data/qid-lines.csv 
mv data/cross_data_sbir956 data/cross_data
printf "python2 4-calc-metric.py sbir956-pred.dat\n"
python2 4-calc-metric.py sbir956-pred.dat
mv data/cross_data data/cross_data_sbir956

rm data/qid-lines.csv
