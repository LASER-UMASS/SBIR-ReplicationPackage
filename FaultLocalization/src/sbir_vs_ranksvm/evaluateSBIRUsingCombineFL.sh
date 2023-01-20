#!/bin/bash
# The purpose of this script is to evaluate SBIR (10 seeds) using the combineFL framework.
# As SBIR is the combined result of SBFL and Blues, we do not need any training. 
# We create a cross validation dataset and use the SBIR scores as the 
# predictions to compute the FL performance. 
# Comment out the sbfl and blues features in 1-combine815.py and then execute this script. 
# The folders data/cross_data_sbir<n> (n = seed) will store the computed SBIR results. 

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir1_815.json/sbfl_blues_sbir1_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir1-pred.dat"
./sbir-pred.sh sbir1-pred.dat
echo "cp qid-lines.csv qid-lines-sbir1.csv"
cp qid-lines.csv qid-lines-sbir1.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir1-pred.dat"
python2 4-calc-metric.py sbir1-pred.dat
echo "mv data/cross_data data/cross_data_sbir1"
mv data/cross_data data/cross_data_sbir1

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir1_815.json/sbfl_blues_sbir7_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir7-pred.dat"
./sbir-pred.sh sbir7-pred.dat
echo "cp qid-lines.csv qid-lines-sbir7.csv"
cp qid-lines.csv qid-lines-sbir7.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir7-pred.dat"
python2 4-calc-metric.py sbir7-pred.dat
echo "mv data/cross_data data/cross_data_sbir7"
mv data/cross_data data/cross_data_sbir7

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir7_815.json/sbfl_blues_sbir47_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir47-pred.dat"
./sbir-pred.sh sbir47-pred.dat
echo "cp qid-lines.csv qid-lines-sbir47.csv"
cp qid-lines.csv qid-lines-sbir47.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir47-pred.dat"
python2 4-calc-metric.py sbir47-pred.dat
echo "mv data/cross_data data/cross_data_sbir47"
mv data/cross_data data/cross_data_sbir47

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir47_815.json/sbfl_blues_sbir160_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir160-pred.dat"
./sbir-pred.sh sbir160-pred.dat
echo "cp qid-lines.csv qid-lines-sbir160.csv"
cp qid-lines.csv qid-lines-sbir160.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir160-pred.dat"
python2 4-calc-metric.py sbir160-pred.dat
echo "mv data/cross_data data/cross_data_sbir160"
mv data/cross_data data/cross_data_sbir160

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir160_815.json/sbfl_blues_sbir561_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir561-pred.dat"
./sbir-pred.sh sbir561-pred.dat
echo "cp qid-lines.csv qid-lines-sbir561.csv"
cp qid-lines.csv qid-lines-sbir561.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir561-pred.dat"
python2 4-calc-metric.py sbir561-pred.dat
echo "mv data/cross_data data/cross_data_sbir561"
mv data/cross_data data/cross_data_sbir561

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir561_815.json/sbfl_blues_sbir630_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir630-pred.dat"
./sbir-pred.sh sbir630-pred.dat
echo "cp qid-lines.csv qid-lines-sbir630.csv"
cp qid-lines.csv qid-lines-sbir630.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir630-pred.dat"
python2 4-calc-metric.py sbir630-pred.dat
echo "mv data/cross_data data/cross_data_sbir630"
mv data/cross_data data/cross_data_sbir630

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir630_815.json/sbfl_blues_sbir657_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir657-pred.dat"
./sbir-pred.sh sbir657-pred.dat
echo "cp qid-lines.csv qid-lines-sbir657.csv"
cp qid-lines.csv qid-lines-sbir657.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir657-pred.dat"
python2 4-calc-metric.py sbir657-pred.dat
echo "mv data/cross_data data/cross_data_sbir657"
mv data/cross_data data/cross_data_sbir657

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir657_815.json/sbfl_blues_sbir754_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir754-pred.dat"
./sbir-pred.sh sbir754-pred.dat
echo "cp qid-lines.csv qid-lines-sbir754.csv"
cp qid-lines.csv qid-lines-sbir754.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir754-pred.dat"
python2 4-calc-metric.py sbir754-pred.dat
echo "mv data/cross_data data/cross_data_sbir754"
mv data/cross_data data/cross_data_sbir754

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir754_815.json/sbfl_blues_sbir828_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir828-pred.dat"
./sbir-pred.sh sbir828-pred.dat
echo "cp qid-lines.csv qid-lines-sbir828.csv"
cp qid-lines.csv qid-lines-sbir828.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir828-pred.dat"
python2 4-calc-metric.py sbir828-pred.dat
echo "mv data/cross_data data/cross_data_sbir828"
mv data/cross_data data/cross_data_sbir828

rm data/qid-lines.csv
sed -i 's/sbfl_blues_sbir828_815.json/sbfl_blues_sbir956_815.json/g' 1-combine815.py
echo "python2 1-combine815.py"
python2 1-combine815.py
echo "./2-split.sh"
./2-split.sh
echo "./sbir-pred.sh sbir956-pred.dat"
./sbir-pred.sh sbir956-pred.dat
echo "cp qid-lines.csv qid-lines-sbir956.csv"
cp qid-lines.csv qid-lines-sbir956.csv
echo "mv qid-lines.csv data"
mv qid-lines.csv data
echo "python2 4-calc-metric.py sbir956-pred.dat"
python2 4-calc-metric.py sbir956-pred.dat
echo "mv data/cross_data data/cross_data_sbir956"
mv data/cross_data data/cross_data_sbir956

sed -i 's/sbfl_blues_sbir956_815.json/sbfl_blues_sbir1_815.json/g' 1-combine815.py
