import io,json,sys,os
import argparse

class CombineFL:
    def __init__(self):
        self.raw_data_file = 'sbfl_blues_sbir1_815.json'  # or use 'sbfl_blues_sbir<n>_815.json' 
        with io.open(self.raw_data_file) as f:
            self.data = json.load(f)
        self.techniques = set([
            #'sbfl',                     
            #'blues',                    
            'sbir',                   # uncomment sbir and comment sbfl and blues when evaluating SBIR (RAFL)
        ])
        self.projects = [
                ('Chart',8),
                ('Cli',	39),
                ('Closure',174),
                ('Codec',18),
                ('Compress',47),
                ('Csv',16),
                ('Collections',4),
                ('Gson',18),
                ('JacksonCore',26),
                ('JacksonDatabind',111),
                ('JacksonXml',6),
                ('Jsoup',93),
                ('JxPath',22),
                ('Lang',64),
                ('Math',106),
                ('Mockito',38),
                ('Time',25),
        ]
        self.data_dir = 'data'
        self.output_svm_file = 'l2r_format.dat'
        self.new_techniques = set()

    def unique_name(self, project, number):
        return project+str(number)

    def convert_to_svm_format(self, keys):
        if not os.path.exists(self.data_dir):
            os.mkdir(self.data_dir)
        out_path = os.path.join(self.data_dir, self.output_svm_file)
        # clean file content
        with io.open(out_path, 'w') as f:
            pass
        qid = 1
        for proj, numbers in self.projects:
            for i in range(1, 200):
                if proj+str(i) in self.data:
                    lines = self.gen_svm_format(proj,i,qid,keys)
                    f1 = open("qid-lines.csv", "a")
                    f1.write(str(qid) + "," + str(len(lines)) + "\n")
                    f1.close()
                    print '\r', 'handling..',proj, i, 'qid:',qid,'        ',
                    sys.stdout.flush()
                    qid += 1
                    with io.open(out_path, 'a') as f:
                        for l in lines:
                            f.write(unicode(l))
                    
            print
        print '\nDone.'

    def gen_svm_format(self, project, number, qid, keys):
        fault_name = self.unique_name(project, number)
        fault_data = self.data[fault_name]
        lines = []
        for statement in fault_data:
            # is_fault
            faultystr = str(fault_data[statement]['faulty'])
            # qid
            qidstr = 'qid:'+str(qid)
            # features
            features = []
            for i, key in enumerate(keys, start=1):
                if key in fault_data[statement]:
                    feature = str(i)+':'+str(fault_data[statement][key])
                features.append(feature)
            line = faultystr + ' ' + qidstr
            for feature in features:
                line += ' ' + feature
            line += '\n'
            lines.append(line)
        return lines

    def add_in(self, file_path):
        with io.open(file_path) as f:
            add_in_data = json.load(f)
        for fault_name in add_in_data:
            if fault_name not in self.data:
                print 'Error.',fault_name, 'is not a valid fault in dataset. Valid example: closure5'
                return
            new_fault_data = add_in_data[fault_name]
            origin_fault_data = self.data[fault_name]
            for statement in new_fault_data:
                if statement not in origin_fault_data:
                    origin_fault_data[statement] = {}
                    origin_fault_data[statement]['faulty'] = 0
                for key in new_fault_data[statement]:
                    if key in self.techniques or key == 'faulty':
                        print 'Error.', key, 'is a reserved key in original dataset. Please change the keyword in add-in data.'
                        return
                    origin_fault_data[statement][key] = new_fault_data[statement][key]
                    self.new_techniques.add(key)

def main():
    parser = argparse.ArgumentParser(description='Combine and Generate SVMRank file.')
    parser.add_argument('-f', '--add_in_file', help="Add-in data file.")
    args = parser.parse_args()
    if args.add_in_file:
        combine = CombineFL()
        combine.add_in(args.add_in_file)
        combine.convert_to_svm_format(combine.techniques.union(combine.new_techniques))
    else:
        combine = CombineFL()
        print combine.techniques
        combine.convert_to_svm_format(combine.techniques)

if __name__ == '__main__':
    main()
