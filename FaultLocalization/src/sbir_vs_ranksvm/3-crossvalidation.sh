#!/bin/bash
if [ x$1 != x ]; then
    n=$1
else
    n=10
fi
# split
# for (( i=0; i<$n; i++ )) do
#     python split.py $i &
# done
# wait

# learn
for (( i=0; i<$n; i++ )) do
    SVMRank/svm_rank_learn -c 1 data/cross_data/$i/train.dat data/cross_data/$i/svmrank-model.dat &
done
wait

# predict
for (( i=0; i<$n; i++ )) do
    SVMRank/svm_rank_classify data/cross_data/$i/test.dat data/cross_data/$i/svmrank-model.dat data/cross_data/$i/svmrank-pred.dat &
done
wait

