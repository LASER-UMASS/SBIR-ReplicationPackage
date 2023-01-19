import sys

project=sys.argv[1]
swarmscript=sys.argv[2]

defectids = []

f = open(swarmscript)

for line in f:
	defectids.append(line.split()[3].strip())

f.close()

for i in defectids:
	print("bash computeSBFL.sh " + project + " " + i)




