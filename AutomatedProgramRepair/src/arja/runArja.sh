# the purpose of this script is to run Arja on Defects4j defect

#!/bin/bash

unset DISPLAY
export ANT_HOME=<path-to-apache-ant-1.9.13>
export DEFECTS4J_HOME=<path-to-defects4j>
export JAVA_HOME=<path-to-java-8-openjdk-amd64>
export PATH=$ANT_HOME/bin:$JAVA_HOME/bin/:$DEFECTS4J_HOME/framework/bin/:$PATH

project=$1
bugid=$2
rootdir=$3
project_d4j=$4
fldir=$5
patchdir=$6

echo $project
echo $bugid
echo $rootdir
echo $project_d4j
echo $fldir
echo $patchdir

java -version

workdir="$rootdir"/"$project"/"$project"_"$bugid"_buggy/

echo $workdir

rm -rf $workdir

defects4j checkout -p $project_d4j -v "$bugid"b -w $workdir

defects4j compile -w $workdir

defects4j test -w $workdir

dir_src_classes=$(defects4j export -p dir.src.classes -w $workdir  | xargs)
dir_bin_classes=$(defects4j export -p dir.bin.classes -w $workdir  | xargs)
dir_bin_tests=$(defects4j export -p dir.bin.tests -w $workdir | xargs)
cp_compile=$(defects4j export -p cp.compile -w $workdir | xargs)
cp_test=$(defects4j export -p cp.test -w $workdir | xargs)

echo $dir_src_classes
echo $dir_bin_classes
echo $dir_bin_tests
echo $cp_compile
echo "#################################"
echo "#################################"
echo $cp_test 
echo "#################################"
echo "#################################"
cp_test_corrected=$(echo $cp_test | sed -e "s/buggy\/file:/buggy:/g")
echo "#################################"
echo "#################################"

echo "java -cp lib/*:bin us.msu.cse.repair.Main Arja -DsrcJavaDir "$workdir/$dir_src_classes" -DbinJavaDir "$workdir/$dir_bin_classes" -DbinTestDir "$workdir/$dir_bin_tests" -Ddependences "$cp_compile:$cp_test_corrected" -DgzoltarDataDir $fldir -DdiffFormat true -Dthr 0 -DpatchOutputRoot " "$patchdir"/"$project"/"$project"_"$bugid" 
java -cp lib/*:bin us.msu.cse.repair.Main Arja -DsrcJavaDir "$workdir/$dir_src_classes" -DbinJavaDir "$workdir/$dir_bin_classes" -DbinTestDir "$workdir/$dir_bin_tests" -Ddependences "$cp_compile:$cp_test_corrected" -DgzoltarDataDir $fldir -DdiffFormat true -Dthr 0 -DpatchOutputRoot "$patchdir"/"$project"/"$project"_"$bugid"

rm -rf $workdir
