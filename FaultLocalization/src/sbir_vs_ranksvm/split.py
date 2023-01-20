import io
import os
import random
import sys

all_data_file = os.path.join('data','l2r_format.dat')

if len(sys.argv) > 1:
    outdir = sys.argv[1]
    fold_number = int(sys.argv[2])
    test_id = int(outdir) % fold_number
else:
    print 'Usage: split.py <outdir> <fold-number>.'
    sys.exit(0)
outdir = os.path.join('data', 'cross_data', outdir)
if not os.path.exists(outdir):
    os.makedirs(outdir)
print 'Writing Train/Test data to', outdir

qid_list = set()

with io.open(all_data_file) as f:
    for line in f:
        qid = int(line.split()[1].split(':')[1])
        qid_list.add(qid)

qid_list = list(qid_list)

random.seed(2018)
random.shuffle(qid_list)

sets = []
for i in range(fold_number):
    sets.append([])
cur = 0
for qid in qid_list:
    sets[cur].append(qid)
    cur += 1
    cur %= fold_number

test_set = set(sets[test_id])

train_file = os.path.join(outdir, 'train.dat')
test_file = os.path.join(outdir, 'test.dat')

ftrain = io.open(train_file, 'w')
ftest = io.open(test_file, 'w')

with io.open(all_data_file) as f:
    for line in f:
        qid = int(line.split()[1].split(':')[1])
        if qid in test_set:
            ftest.write(line)
        else:
            ftrain.write(line)
ftest.close()
ftrain.close()

print test_set
