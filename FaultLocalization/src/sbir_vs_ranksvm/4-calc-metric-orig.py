import operator as op
import io
import os
import sys

#pred_f = 'svmrank-pred.dat'
pred_f = 'sbir1-pred.dat'
def nCr(n, r):
    r = min(r, n-r)
    if r == 0:
        return 1
    numer = reduce(op.mul, xrange(n, n-r, -1))
    demon = reduce(op.mul, xrange(1, r+1))
    return numer // demon

def E_inspect(st, en, nf):
    expected = float(st)
    n = en - st + 1
    for k in xrange(1, n-nf+1):
        term = float(nCr(n-k-1, nf-1) * k) / nCr(n, nf)
        expected += term
    return expected

# List = [
#   {
#       is_fault: 1 / 2,
#       score: 0.123
#   },
# ]
def get_E_inspect(lst):
    sorted_lst = sorted(lst, key=lambda f: f['score'], reverse=True)
    pos = -1
    for i, f in enumerate(sorted_lst):
        if f['is_fault'] == 1:
            pos = i
            pos_score = f['score']
            break
    if pos == -1:
        return -1
    start = 0
    end = len(sorted_lst) -1
    for i in range(pos-1, -1, -1):
        f = sorted_lst[i]
        if f['score'] != pos_score:
            start = i+1
            break
    for i in range(pos+1, len(sorted_lst)):
        f = sorted_lst[i]
        if f['score'] != pos_score:
            end = i-1
            break
    count = 0
    for i in range(start, end+1):
        if sorted_lst[i]['is_fault'] == 1:
            count += 1
    return E_inspect(start+1, end+1, count)

def read_info_ranksvm(num):
    # data -> bug(qid) -> pos(line) -> score / is_fault
    data = {}
    curdir = 'data/cross_data'
    curdir = os.path.join(curdir, str(num))
    pred_file = os.path.join(curdir, pred_f)
    test_file = os.path.join(curdir, 'test.dat')
    with io.open(test_file) as f:
        test_data = f.readlines()
    with io.open(pred_file) as f:
        pred_data = f.readlines()
    for i in range(len(pred_data)):
        test_line = test_data[i]
        pred_line = pred_data[i]
        is_fault = int(test_line.split(' ', 1)[0])
        qid = test_line.split(' ', 2)[1]
        score = float(pred_line)
        if qid not in data:
            data[qid] = []
        item = {'score': score, 'is_fault': is_fault}
        data[qid].append(item)
    return data

def qid_to_lines():
    data = {}
    with io.open('data/qid-lines.csv') as f:
        raw = f.readlines()
        for line in raw:
            qid = int(line.split(',')[0])
            lines = int(line.split(',')[1])
            data[qid] = lines
    return data

def main():
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    else:
        n = 10
    E_pos_list = []
    EXAM_list = []
    qid2line = qid_to_lines()
    for i in range(n):
        print '\r','Handle', i+1, '/', n,
        sys.stdout.flush()
        data = read_info_ranksvm(i)
        for key in data.keys():
            # key: u'qid:117'
            E_inspect = get_E_inspect(data[key])
            E_pos_list.append(E_inspect)
            # calc EXAM
            qid = int(key.split(':')[1])
            lines = qid2line[qid]
            EXAM = E_inspect / float(lines)
            EXAM_list.append(EXAM)
    top = []
    top.append(len(filter(lambda item: item < 1.01 and item > 0, E_pos_list)))
    top.append(len(filter(lambda item: item < 25.01 and item > 0, E_pos_list)))
    top.append(len(filter(lambda item: item < 50.01 and item > 0, E_pos_list)))
    top.append(len(filter(lambda item: item < 100.01 and item > 0, E_pos_list)))
    print '\nTop 1/25/50/100:', top
    EXAM_list = [e for e in EXAM_list if e > 0]
    print 'EXAM: ', sum(EXAM_list) / len(EXAM_list)

if __name__ == '__main__':
    main()
