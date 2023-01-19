#!/bin/bash

root="<path-to-SBFL>"
project=$1
bugid=$2

export D4J_HOME=$root/defects4j/
export GZOLTAR_CLI_JAR=$root/gzoltar/gzoltar-1.7.2.201905090602/lib/gzoltarcli.jar 
export GZOLTAR_AGENT_JAR=$root/gzoltar/gzoltar-1.7.2.201905090602/lib/gzoltaragent.jar 

./justgzoltar.sh --project $project --bug $bugid --output_dir $root/sbfl_fl_results --tool developer

python3 crush-matrix --formula ochiai --matrix $root/sbfl_fl_results/$project/$bugid/matrix --element-type 'Statement' --element-names $root/sbfl_fl_results/$project/$bugid/spectra --total-defn tests --output $root/sbfl_fl_results/$project/$bugid/stmt-susps.txt
