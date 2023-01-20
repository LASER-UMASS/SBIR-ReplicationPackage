# example cmd to run: `bash runSimFix.sh chart 1 chart_1_buggy Chart` 
#!/bin/bash

export DEFECTS4J_HOME=/home/manish/SBIR-ReplicationPackage/AutomatedProgramRepair/src/apr-tools/defects4j #<path-to-SBFL/defects4j>
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ #<path to Java-8>
export PATH=$DEFECTS4J_HOME/framework/bin:$PATH

project=$1
bugid=$2
workdir=$3
project_d4j=$4

echo $project
echo $bugid
echo $workdir
echo $project_d4j

rm -rf "$workdir"/"$project"/"$project"_"$bugid"_buggy/

defects4j checkout -p $project_d4j -v "$bugid"b -w "$workdir"/"$project"/"$project"_"$bugid"_buggy

defects4j compile -w "$workdir"/"$project"/"$project"_"$bugid"_buggy

defects4j test -w "$workdir"/"$project"/"$project"_"$bugid"_buggy

java -jar simfix.jar --proj_home="$workdir" --proj_name="$project" --bug_id="$bugid"

