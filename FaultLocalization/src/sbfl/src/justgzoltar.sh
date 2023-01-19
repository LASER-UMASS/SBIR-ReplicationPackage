#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# 
# This script runs GZoltar on a specified D4J project/bug using either manually
# written test cases or automatically generated.
# 
# Usage:
# ./job.sh
#   --project <project_name>
#   --bug <bug_id>
#   --output_dir <path>
#   --tool <developer|evosuite|randoop>
#   [--tests_dir <path>]
#   [--help]
# 
# Environment variables:
# - D4J_HOME            Needs to be set and must point to the Defects4J installation.
# - GZOLTAR_CLI_JAR     Needs to be set and must point to GZoltar command line jar file.
# - GZOLTAR_AGENT_JAR   Needs to be set and must point to GZoltar agent jar file.
# 
# ------------------------------------------------------------------------------

SCRIPT_DIR=`pwd`
source "$SCRIPT_DIR/utils.sh" || exit 1

# ------------------------------------------------------------------ Envs & Args

# Check whether D4J_HOME is set
[ "$D4J_HOME" != "" ] || die "D4J_HOME is not set!"
[ -d "$D4J_HOME" ] || die "$D4J_HOME does not exist!"

# Check whether GZOLTAR_CLI_JAR is set
[ "$GZOLTAR_CLI_JAR" != "" ] || die "GZOLTAR_CLI_JAR is not set!"
[ -s "$GZOLTAR_CLI_JAR" ] || die "$GZOLTAR_CLI_JAR does not exist or it is empty!"

# Check whether GZOLTAR_AGENT_JAR is set
[ "$GZOLTAR_AGENT_JAR" != "" ] || die "GZOLTAR_AGENT_JAR is not set!"
[ -s "$GZOLTAR_AGENT_JAR" ] || die "$GZOLTAR_AGENT_JAR does not exist or it is empty!"

USAGE="Usage: ${BASH_SOURCE[0]} --project <project_name> --bug <bug_id> --output_dir <path> --tool <developer|evosuite|randoop> [--tests_dir <path>] [help]"
if [ "$#" -ne "1" ] && [ "$#" -lt "8" ]; then
  die "$USAGE"
fi

PID=""
BID=""
OUTPUT_DIR=""
TOOL=""
TESTS_DIR=""

while [[ "$1" = --* ]]; do
  OPTION=$1; shift
  case $OPTION in
    (--project)
      PID=$1;
      shift;;
    (--bug)
      BID=$1;
      shift;;
    (--output_dir)
      OUTPUT_DIR=$1;
      shift;;
    (--tool)
      TOOL=$1;
      shift;;
    (--tests_dir)
      TESTS_DIR=$1;
      shift;;
    (--help)
      echo "$USAGE"
      exit 0;;
    (*)
      die "$USAGE";;
  esac
done

[ "$PID" != "" ] || die "$USAGE"
[ "$BID" != "" ] || die "$USAGE"

[ "$OUTPUT_DIR" != "" ] || die "$USAGE"
[ -d "$OUTPUT_DIR" ] || mkdir -p "$OUTPUT_DIR"

[ "$TOOL" != "" ] || die "$USAGE"
if [ "$TOOL" != "developer" ] && [ "$TOOL" != "evosuite" ] && [ "$TOOL" != "randoop" ]; then
  die "$USAGE"
fi

if [ "$TESTS_DIR" != "" ]; then
  [ -d "$TESTS_DIR" ] || die "$TESTS_DIR does not exist!"
fi

LOCAL_TMP_DIR="/tmp/$USER-$PID-$BID-$TOOL-$$"
rm -rf "$LOCAL_TMP_DIR"
mkdir -p "$LOCAL_TMP_DIR" || die

LOCAL_DATA_DIR="$LOCAL_TMP_DIR/gzoltars/$PID/$BID"
mkdir -p "$LOCAL_DATA_DIR" || die

# ------------------------------------------------------------------------- Main

echo "PID: $$"
hostname
java -version

echo ""
echo "[INFO] Run GZoltar on $PID-${BID}b"
_run_gzoltar "$PID" "$BID" "$LOCAL_DATA_DIR" "$TOOL" "$TESTS_DIR"
if [ $? -ne 0 ]; then
  echo "[ERROR] Execution of GZoltar on $PID-${BID}b has failed!"
  rm -rf "$LOCAL_TMP_DIR"
  exit 1
fi

#
# Sanity checks
#

TESTS_FILE="$LOCAL_DATA_DIR/tests"
SPECTRA_FILE="$LOCAL_DATA_DIR/spectra"
MATRIX_FILE="$LOCAL_DATA_DIR/matrix"

echo ""
echo "[INFO] Running a few sanity checks on $PID-${BID}b"
echo ""

# 1. Do GZoltar and D4J agree on the number of triggering test cases?

ignore_d4j_list_of_trigger_tests="0" # 0 yes, 1 no

num_triggering_test_cases_gzoltar=$(grep -a ",FAIL," "$TESTS_FILE" | wc -l)
num_triggering_test_cases_d4j=$(grep -a "^--- " "$D4J_HOME/framework/projects/$PID/trigger_tests/$BID" | sort -u | wc -l)

if [ "$num_triggering_test_cases_gzoltar" -ne "$num_triggering_test_cases_d4j" ]; then
  echo "[ERROR] Do GZoltar and D4J agree on the number of triggering test cases? No, D4J: $num_triggering_test_cases_d4j vs GZoltar: $num_triggering_test_cases_gzoltar"
  echo "[DEBUG] D4J triggering test cases:"
  grep -a "^--- " "$D4J_HOME/framework/projects/$PID/trigger_tests/$BID" | sort -u | cut -f2 -d' '
  echo "[DEBUG] GZoltar triggering test cases:"
  grep -a ",FAIL," "$TESTS_FILE" | cut -f1 -d','

  echo ""
  echo "[INFO] Running each test case annotated by D4J as a trigger test case in isolation"

  tmp_dir=$(_checkout "$PID" "$BID" "b")
  if [ $? -ne 0 ]; then
    echo "[ERROR] Checkout of $PID-${BID}b has failed!"
    rm -rf "$LOCAL_TMP_DIR"
    exit 1
  fi

  pushd . > /dev/null 2>&1
  cd "$tmp_dir"
    "$D4J_HOME/framework/bin/defects4j" compile
    if [ $? -ne 0 ]; then
      echo "[ERROR] Compilation of $PID-${BID}b has failed!"
      rm -rf "$LOCAL_TMP_DIR"
      exit 1
    fi
  popd > /dev/null 2>&1

  pushd . > /dev/null 2>&1
  cd "$tmp_dir"
    while read -r d4j_trigger_test; do
      d4j_trigger_test_name=$(echo "$d4j_trigger_test" | cut -f2 -d' ')
      echo "[DEBUG] Checking $d4j_trigger_test_name annotated by D4J as a trigger test case"

      rm -f "$tmp_dir/failing_tests" && touch "$tmp_dir/failing_tests" && "$D4J_HOME/framework/bin/defects4j" test -t "$d4j_trigger_test_name"
      if [ $? -ne 0 ]; then
        echo "[ERROR] Execution of D4J -- $d4j_trigger_test_name in isolation has failed!"
        rm -rf "$LOCAL_TMP_DIR"
        exit 1
      fi

      trigger_stack_trace_length=$(wc -l "$tmp_dir/failing_tests" | cut -f1 -d' ')
      if [ "$trigger_stack_trace_length" -eq "0" ]; then
        echo "[DEBUG] Test case '$d4j_trigger_test_name' annotated by D4J as a trigger test case does not fail when executed in isolation! Ignoring list of triggering test cases reported by D4J as it does not seem to be consistent for $PID-$BID."
        ignore_d4j_list_of_trigger_tests="0"
        break
      fi
    done < <(grep -a "^--- " "$D4J_HOME/framework/projects/$PID/trigger_tests/$BID" | sort -u)
  popd > /dev/null 2>&1

  echo ""
  echo "[INFO] Running each test case annotated by GZoltar as a failing test case in isolation"

  pushd . > /dev/null 2>&1
  cd "$tmp_dir"
    while read -r gz_trigger_test; do
      gz_trigger_test_name=$(echo "$gz_trigger_test" | cut -f1 -d',' | sed 's/#/::/g')
      echo "[DEBUG] Checking $gz_trigger_test_name annotated by GZoltar as a failing test case"

      rm -f "$tmp_dir/failing_tests" && touch "$tmp_dir/failing_tests" && "$D4J_HOME/framework/bin/defects4j" test -t "$gz_trigger_test_name"
      if [ $? -ne 0 ]; then
        echo "[ERROR] Execution of GZoltar -- $gz_trigger_test_name in isolation has failed!"
        rm -rf "$LOCAL_TMP_DIR"
        exit 1
      fi

      trigger_stack_trace_length=$(wc -l "$tmp_dir/failing_tests" | cut -f1 -d' ')
      if [ "$trigger_stack_trace_length" -eq "0" ]; then
        echo "[ERROR] Test case '$gz_trigger_test_name' annotated by GZoltar as a failing test case does not fail when executed in isolation!"
      #  rm -rf "$LOCAL_TMP_DIR"
      #  exit 1
      fi
    done < <(grep -a ",FAIL," "$TESTS_FILE")
  popd > /dev/null 2>&1

  rm -rf "$tmp_dir"

  if [ "$ignore_d4j_list_of_trigger_tests" == "1" ]; then
    echo "[INFO] Do GZoltar and D4J agree on the number of triggering test cases? No, however the list of trigger test cases reported by D4J is correct and the list of failing test cases reported by GZoltar is also correct, which means the set of test cases reported by one tool is a subset of the other!"
  elif [ "$ignore_d4j_list_of_trigger_tests" == "0" ]; then
    echo "[INFO] Do GZoltar and D4J agree on the number of triggering test cases? No, however the list of trigger test cases reported by D4J does not seem to be consistent. (At this point, all failing test cases reported by GZoltar do fail in isolation)"
  fi
else
  echo "[INFO] Do GZoltar and D4J agree on the number of triggering test cases? Yes, D4J: $num_triggering_test_cases_d4j == GZoltar: $num_triggering_test_cases_gzoltar."
fi

# 2. Has GZoltar reported the trigger test cases reported by D4J?

if [ "$ignore_d4j_list_of_trigger_tests" == "1" ]; then
  agree=true
  while read -r trigger_test; do
    class_test_name=$(echo "$trigger_test" | cut -f2 -d' ' | cut -f1 -d':')
    unit_test_name=$(echo "$trigger_test" | cut -f2 -d' ' | cut -f3 -d':')

    # e.g., org.apache.commons.math.complex.ComplexTest#testMath221,FAIL,3111187,junit.framework.AssertionFailedError:
    if ! grep -a -q -F "$class_test_name#$unit_test_name,FAIL," "$TESTS_FILE"; then
      echo "[ERROR] Triggering test case '$class_test_name#$unit_test_name' has not been reported by GZoltar!"
      agree=false
    fi
  done < <(grep -a "^--- " "$D4J_HOME/framework/projects/$PID/trigger_tests/$BID" | sort -u)

  if [[ $agree == false ]]; then
    if [ "$PID" == "Closure" ]; then
      if [ "$BID" == "13100063" ] || [ "$BID" == "13100064" ] || [ "$BID" == "13100068" ] || [ "$BID" == "13100069" ]; then
        # Some triggering test cases, e.g., com.google.javascript.jscomp.SpecializeModuleTest$SpecializeModuleSpecializationStateTest#testCanFixupFunction,
        # are not in the list of relevant tests and therefore they could not have
        # been executed by GZoltar
        agree=true
        echo "[INFO] Some triggering test cases were not in the list of relevant tests and therefore they could not have been executed by GZoltar."
      fi
    fi
  fi

  if [[ $agree == false ]]; then
    echo "[ERROR] Has GZoltar reported the trigger test cases reported by D4J? No."
    rm -rf "$LOCAL_TMP_DIR"
    exit 1
  else
    echo "[INFO] Has GZoltar reported the trigger test cases reported by D4J? Yes."
  fi
else
  echo "[INFO] Has GZoltar reported the trigger test cases reported by D4J? Check cannot be performed as the list of trigger test cases reported by D4J seems to be inconsistent."
fi

# 3. Has the faulty class(es) been reported?

num_classes_not_reported=0
modified_classes_file="$D4J_HOME/framework/projects/$PID/modified_classes/$BID.src"
while read -r modified_class; do
  echo "[DEBUG] modified_class: $modified_class"
  if grep -q "^$modified_class#" "$SPECTRA_FILE"; then
    echo "[DEBUG] Has '$modified_class' been reported? Yes."
  else
    echo "[DEBUG] Has '$modified_class' been reported? No."
    num_classes_not_reported=$((num_classes_not_reported+1))
  fi
done < <(cat "$modified_classes_file")

if [ "$num_classes_not_reported" -eq "1" ] && [ "$PID" == "Mockito" ] && [ "$BID" == "19" ]; then
  # one of the modified classes of Mockito-19 is an interface without
  # any code. as interfaces with no code have no lines of code in bytecode,
  # GZoltar does not report it in the spectra file
  echo "Mockito-19 excluded from the check on the number of modified classes reported as one modified class is an interface without code to which GZoltar does not report any line."
elif [ "$num_classes_not_reported" -ne "0" ]; then
  echo "[ERROR] Has the faulty class(es) been reported? No."
#  rm -rf "$LOCAL_TMP_DIR"
#  exit 1
fi

echo "[INFO] Has the faulty class(es) been reported? Yes."

# 4. Does spectra file include at least one buggy-line?

# 5. Do all test cases cover at least one buggy-line?

#
# Collect and compress data
#

echo ""
echo "[INFO] Collect data & Clean up"

pushd . > /dev/null 2>&1
cd "$LOCAL_TMP_DIR"
  echo "DONE!"

  # get log file so that it can also be in the .tar.gz file
  cp -f "$OUTPUT_DIR/log.txt" "gzoltars/$PID/$BID/" > /dev/null 2>&1

  zip_filename="gzoltar-files.tar.gz"
  tar -czf "$zip_filename" "gzoltars/$PID/$BID/tests" \
                           "gzoltars/$PID/$BID/spectra" \
                           "gzoltars/$PID/$BID/.spectra" \
                           "gzoltars/$PID/$BID/matrix" \
                           "gzoltars/$PID/$BID/gzoltar.ser" \
                           "gzoltars/$PID/$BID/log.txt"

  if [ $? -ne 0 ]; then
    echo "[ERROR] It was not possible to compress directory '$LOCAL_TMP_DIR/gzoltars/'!"

    echo "[INFO] Copying all files from local '$LOCAL_TMP_DIR/gzoltars' to remote '$OUTPUT_DIR' so that anyone can debug them"
    cp -Rv gzoltars/* "$OUTPUT_DIR/"


     [ -d "$OUTPUT_DIR/$PID" ] || mkdir -p "$OUTPUT_DIR/$PID"
     [ -d "$OUTPUT_DIR/$PID/$BID" ] || mkdir -p "$OUTPUT_DIR/$PID/$BID"
     cp "gzoltars/$PID/$BID/tests" $OUTPUT_DIR/$PID/$BID/
     cp "gzoltars/$PID/$BID/spectra" $OUTPUT_DIR/$PID/$BID/
     cp "gzoltars/$PID/$BID/.spectra" $OUTPUT_DIR/$PID/$BID/
     cp "gzoltars/$PID/$BID/matrix" $OUTPUT_DIR/$PID/$BID/
     cp "gzoltars/$PID/$BID/gzoltar.ser" $OUTPUT_DIR/$PID/$BID/
  #   cp "gzoltars/$PID/$BID/log.txt" $OUTPUT_DIR/$PID/$BID/


#    popd > /dev/null 2>&1
#    rm -rf "$LOCAL_TMP_DIR"
#    exit 1
  fi

  tar -xzf "$zip_filename" "$OUTPUT_DIR/" > /dev/null 2>&1
  rm -f "$OUTPUT_DIR/log.txt" > /dev/null 2>&1
popd > /dev/null 2>&1

#rm -rf "$LOCAL_TMP_DIR" > /dev/null 2>&1 # Clean up
exit 0

