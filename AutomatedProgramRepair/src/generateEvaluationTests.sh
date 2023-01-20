# the purpose of this script is to generate held-out evaluation tests that 
# cover developer-modified methods using EvoSuite.
# inputs: Project, BugID, TestID, <path-to> Output dir, search budget(time in sec), seed
# example cmd: bash generateEvaluationTests.sh Chart 1 1 data/all_eval_tests/ 720 1

export D4J_HOME=<path-to-defects4j>
export JAVA_HOME=<path-to-Java-8>
export PATH=$D4J_HOME/framework/bin/:$PATH

project=$1
bugid=$2
testid=$3
outputdir=$4
budget=$5
seed=$6
echo "gen_tests.pl -g evosuite -p $project -v $bugid"f" -n $testid -o $outputdir -b $budget -s $seed" 
gen_tests.pl -g evosuite -p $project -v $bugid"f" -n $testid -o $outputdir -b $budget -s $seed

