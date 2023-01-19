#!/usr/bin/env bash

PWD=$(cd `dirname ${BASH_SOURCE[0]}` && pwd)

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"$D4J_HOME

export MALLOC_ARENA_MAX=1 # Iceberg's requirement
export TZ='America/Los_Angeles' # some D4J's requires this specific TimeZone

export _JAVA_OPTIONS="-Xmx6144M -XX:MaxHeapSize=4096M"
export MAVEN_OPTS="-Xmx2048M"
export ANT_OPTS="-Xmx6144M -XX:MaxHeapSize=4096M"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Speed up grep command
alias grep="LANG=C grep"

NUM_CPUS=-1
PROCESS_IDS=()
CORE_INDEX=0

#
# Prints error message to the stdout and exit.
#
die() {
  echo "$@" >&2
  exit 1
}

#
# Checks whether script has been executed on a cluster, e.g., "Son of Grid
# Engine" (SGE) or not. Return true ('0') if yes, otherwise it returns false
# ('1')
#
_am_I_a_cluster() {
  if ! qsub -help > /dev/null 2>&1; then
    return 1 # false
  fi

  return 0 # true
}

#
# Determines the number of cpus/cores available.
#
_how_many_cpus() {
  num_cpus=$(awk -F: '/^physical/ && !ID[$2] { P++; ID[$2]=1 }; /^cpu cores/ { CORES=$2 }; END { print CORES*P }' /proc/cpuinfo)
  if [ $? -ne 0 ]; then
    die "Failed to get number of CPUs available"
  fi

  echo "$num_cpus"
  return 0
}

#
# Keeps record of all processes that are sent to background to run.
#
_register_background_process() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid>"
  if [ "$#" != 1 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  local background_process_pid=$1

  CORE_INDEX=$((CORE_INDEX+1))
  PROCESS_IDS+=($background_process_pid)

  return 0
}

#
# Waits until all background jobs finish.
#
_wait_for_jobs() {
  echo "[DEBUG] Waiting for pids ${PROCESS_IDS[@]} ..." >&2
  date >&2
  wait "${PROCESS_IDS[@]}" >&2
  date >&2
  echo "[DEBUG] Done ..." >&2

  return 0
}

#
# If no more jobs can be executed, because the maximum number of jobs in
# parallel has been reached, this function waits for the running jobs to finish.
#
_can_more_jobs_be_submitted() {
  if [ "$NUM_CPUS" -eq "-1" ]; then
    # init number of cpus available
    NUM_CPUS=$(_how_many_cpus)
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi

  if [ "$CORE_INDEX" -eq "$NUM_CPUS" ]; then
    _wait_for_jobs;

    PROCESS_IDS=() # reset list of pids
    CORE_INDEX=0 # reset counter
  fi

  return 0
}

#
# Checkouts a D4J's project-bug.
#
_checkout() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid> <bid> <fixed (f) or buggy (b)>"
  if [ "$#" != 3 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  local pid="$1"
  local bid="$2"
  local version="$3" # either b or f

  local output_dir="/tmp/$USER-$$-$pid-$bid"
  rm -rf "$output_dir"; mkdir -p "$output_dir"
  "$D4J_HOME/framework/bin/defects4j" checkout -p "$pid" -v "${bid}$version" -w "$output_dir"
  if [ $? -ne 0 ]; then
    if _am_I_a_cluster; then
      rm -rf "$output_dir"

      # trying another directory
      output_dir="/scratch/$USER-$$-$pid-$bid"
      rm -rf "$output_dir"; mkdir -p "$output_dir"
      "$D4J_HOME/framework/bin/defects4j" checkout -p "$pid" -v "${bid}$version" -w "$output_dir" || return 1
    else
      return 1
    fi
  fi

  if [ "$pid" == "Time" ]; then
    if [ "$bid" -eq "18" ] || [ "$bid" -eq "22" ] || [ "$bid" -eq "24" ] || [ "$bid" -eq "27" ]; then
      # For Time-{18, 22, 24, and 27}, test case 'org.joda.time.TestPeriodType::testForFields4'
      # only fails when executed in isolation, i.e., it does not fail when it is
      # executed in the same JVM as other test cases from the same test class
      # but it does fail if executed in a single JVM. As it does not cover any
      # buggy code, it is safe to conclude it is a dependent test case and could
      # be excluded. Ideally, it should be discarded by the D4J checkout command,
      # however, as the same test class, including test case 'testForFields4',
      # is also executed by other Time bugs we took a conservative approach and
      # only discard it for bugs Time-{18, 22, 24, and 27}.
      pushd . > /dev/null 2>&1
      cd "$output_dir"
        echo "--- org.joda.time.TestPeriodType::testForFields4" > extra.dependent_tests
        "$D4J_HOME/framework/util/rm_broken_tests.pl" extra.dependent_tests $("$D4J_HOME/framework/bin/defects4j" export -p dir.src.tests) || return 1
      popd > /dev/null 2>&1
    fi
  fi

  echo "$output_dir"
  return 0
}

#
# Returns the test classpath of a previously checkout D4J's project-bug.
#
_get_test_classpath() {
  local USAGE="Usage: ${FUNCNAME[0]} <checkout_dir>"
  if [ "$#" != 1 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  local checkout_dir="$1"
  [ -d "$checkout_dir" ] || die "[ERROR] $checkout_dir does not exist!"

  cp=$(cd "$checkout_dir" > /dev/null 2>&1 && \
       $D4J_HOME/framework/bin/defects4j compile > /dev/null 2>&1 && \
       $D4J_HOME/framework/bin/defects4j export -p cp.test) || die "[ERROR] Get classpath has failed!"
  [ "$cp" != "" ] || die "[ERROR] test-classpath is empty!"

  echo "$cp"
  return 0
}

#
# Return full path of the target directory of source classes.
#
_get_src_classes_dir() {
  local USAGE="Usage: ${FUNCNAME[0]} <checkout_dir>"
  if [ "$#" != 1 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  local checkout_dir="$1"
  [ -d "$checkout_dir" ] || die "[ERROR] $checkout_dir does not exist!"
  
  src_classes_dir=$(cd "$checkout_dir" > /dev/null 2>&1 && \
                     $D4J_HOME/framework/bin/defects4j compile > /dev/null 2>&1 && \
                     $D4J_HOME/framework/bin/defects4j export -p dir.bin.classes) || die "[ERROR] Get test classes dir has failed!"
  [ "$src_classes_dir" != "" ] || die "[ERROR] src-classes-dir is empty!"

  echo "$checkout_dir/$src_classes_dir" # Return full path
  return 0
}

#
# Return full path of the target directory of test classes.
#
_get_test_classes_dir() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid> <bid> <checkout_dir>"
  if [ "$#" != 3 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  local pid="$1"
  local bid="$2"
  local checkout_dir="$3"
  [ -d "$checkout_dir" ] || die "[ERROR] $checkout_dir does not exist!"

  test_classes_dir=$(cd "$checkout_dir" > /dev/null 2>&1 && \
                     $D4J_HOME/framework/bin/defects4j compile > /dev/null 2>&1 && \
                     $D4J_HOME/framework/bin/defects4j export -p dir.bin.tests)
  if [ $? -ne 0 ]; then
    if [ "$pid" == "Chart" ]; then
      test_classes_dir="build-tests"
    elif [ "$pid" == "Closure" ]; then
      test_classes_dir="build/test"
    elif [ "$pid" == "Lang" ]; then
      if [ "$bid" -ge "1" ] && [ "$bid" -le "20" ]; then
        test_classes_dir="target/tests"
      elif [ "$bid" -ge "21" ] && [ "$bid" -le "41" ]; then
        test_classes_dir="target/test-classes"
      elif [ "$bid" -ge "42" ] && [ "$bid" -le "65" ]; then
        test_classes_dir="target/tests"
      else
        die "[ERROR] Get test classes dir has failed!"
      fi
    elif [ "$pid" == "Math" ]; then
      test_classes_dir="target/test-classes"
    elif [ "$pid" == "Mockito" ]; then
      if [ "$bid" -ge "1" ] && [ "$bid" -le "11" ]; then
        test_classes_dir="build/classes/test"
      elif [ "$bid" -ge "12" ] && [ "$bid" -le "17" ]; then
        test_classes_dir="target/test-classes"
      elif [ "$bid" -ge "18" ] && [ "$bid" -le "21" ]; then
        test_classes_dir="build/classes/test"
      elif [ "$bid" -ge "22" ] && [ "$bid" -le "38" ]; then
        test_classes_dir="target/test-classes"
      else
        die "[ERROR] Get test classes dir has failed!"
      fi
    elif [ "$pid" == "Time" ]; then
      if [ "$bid" -ge "1" ] && [ "$bid" -le "11" ]; then
        test_classes_dir="target/test-classes"
      elif [ "$bid" -ge "12" ] && [ "$bid" -le "27" ]; then
        test_classes_dir="build/tests"
      else
        die "[ERROR] Get test classes dir has failed!"
      fi
    else
      die "[ERROR] Get test classes dir has failed!"
    fi
  fi
  [ "$test_classes_dir" != "" ] || die "[ERROR] test-classes-dir is empty!"
  [ -d "$checkout_dir/$test_classes_dir" ] || die "[ERROR] $checkout_dir/$test_classes_dir does not exist!"

  echo "$checkout_dir/$test_classes_dir" # Return full path
  return 0
}

#
# Collect the list of unit test methods.
#
_collect_list_of_unit_tests() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid> <bid> <checkout_dir> <output_file>"
  if [ "$#" != 4 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  [ "$D4J_HOME" != "" ] || die "[ERROR] D4J_HOME is not set!"
  [ -d "$D4J_HOME" ] || die "[ERROR] $D4J_HOME does not exist!"

  [ "$GZOLTAR_CLI_JAR" != "" ] || die "[ERROR] GZOLTAR_CLI_JAR is not set!"
  [ -s "$GZOLTAR_CLI_JAR" ] || die "[ERROR] $GZOLTAR_CLI_JAR does not exist!"

  local pid="$1"
  local bid="$2"
  local checkout_dir="$3"
  [ -d "$checkout_dir" ] || die "[ERROR] $checkout_dir does not exist!"
  local output_file="$4"
  >"$output_file" || die "[ERROR] Cannot write to $output_file!"

  test_classpath=$(_get_test_classpath "$checkout_dir")
  if [ $? -ne 0 ]; then
    echo "[ERROR] _get_test_classpath for $pid-${bid}b version has failed!" >&2
    return 1
  fi
  echo "[DEBUG] test_classpath: $test_classpath" >&2

  test_classes_dir=$(_get_test_classes_dir "$pid" "$bid" "$checkout_dir")
  if [ $? -ne 0 ]; then
    echo "[ERROR] _get_test_classes_dir for $pid-${bid}b version has failed!" >&2
    return 1
  fi
  echo "[DEBUG] test_classes_dir: $test_classes_dir" >&2

  local relevant_tests_file="$D4J_HOME/framework/projects/$pid/relevant_tests/$bid"
  [ -s "$relevant_tests_file" ] || die "[ERROR] $relevant_tests_file does not exist or it is empty!"
  echo "[DEBUG] relevant_tests_file: $relevant_tests_file" >&2

  # Some export commands might have removed some build files
  (cd "$checkout_dir" > /dev/null 2>&1 && \
     $D4J_HOME/framework/bin/defects4j compile > /dev/null 2>&1) || die "[ERROR] Failed to compile the project!"

  java -cp $D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR \
    com.gzoltar.cli.Main listTestMethods \
      "$test_classes_dir" \
      --outputFile "$output_file" \
      --includes $(cat "$relevant_tests_file" | sed 's/$/#*/' | sed ':a;N;$!ba;s/\n/:/g') || die "GZoltar listTestMethods command has failed!"
  [ -s "$output_file" ] || die "[ERROR] $output_file does not exist or it is empty!"

  # for jacksondatabind projects, deleting test that triggers exception
  sed -i '/JUNIT,com.fasterxml.jackson.databind.misc.AccessFixTest#testCauseOfThrowableIgnoral/d' $output_file

  return 0
}

#
# Collect the list of classes (and inner classes) that might be faulty.
#
_collect_list_of_likely_faulty_classes() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid> <bid> <checkout_dir> <output_file>"
  if [ "$#" != 4 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  [ "$D4J_HOME" != "" ] || die "[ERROR] D4J_HOME is not set!"
  [ -d "$D4J_HOME" ] || die "[ERROR] $D4J_HOME does not exist!"

  local pid="$1"
  local bid="$2"
  local checkout_dir="$3"
  [ -d "$checkout_dir" ] || die "[ERROR] $checkout_dir does not exist!"
  local output_file="$4"
  >"$output_file" || die "[ERROR] Cannot write to $output_file!"

  local loaded_classes_file="$D4J_HOME/framework/projects/$pid/loaded_classes/$bid.src"
  [ -s "$loaded_classes_file" ] || die "[ERROR] $loaded_classes_file does not exist or it is empty!"
  echo "[DEBUG] loaded_classes_file: $loaded_classes_file" >&2

  # "normal" classes
  local normal_classes=$(cat "$loaded_classes_file" | sed 's/$/:/' | sed ':a;N;$!ba;s/\n//g')
  [ "$normal_classes" != "" ] || die "[ERROR] List of classes is empty!"
  local inner_classes=$(cat "$loaded_classes_file" | sed 's/$/$*:/' | sed ':a;N;$!ba;s/\n//g')
  [ "$inner_classes" != "" ] || die "[ERROR] List of inner classes is empty!"

  echo "$normal_classes$inner_classes" > "$output_file"
  return 0
}

#
# Runs GZoltar fault localization tool on a specific D4J's project-bug.
#
_run_gzoltar() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid> <bid> <data_dir> <tool> <tests dir>"
  if [ "$#" != 4 ] && [ "$#" != 5 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  [ "$D4J_HOME" != "" ] || die "[ERROR] D4J_HOME is not set!"
  [ -d "$D4J_HOME" ] || die "[ERROR] $D4J_HOME does not exist!"

  [ "$GZOLTAR_CLI_JAR" != "" ] || die "[ERROR] GZOLTAR_CLI_JAR is not set!"
  [ -s "$GZOLTAR_CLI_JAR" ] || die "[ERROR] $GZOLTAR_CLI_JAR does not exist or it is empty!"

  [ "$GZOLTAR_AGENT_JAR" != "" ] || die "[ERROR] GZOLTAR_AGENT_JAR is not set!"
  [ -s "$GZOLTAR_AGENT_JAR" ] || die "[ERROR] $GZOLTAR_AGENT_JAR does not exist or it is empty!"

  local pid="$1"
  local bid="$2"
  local data_dir="$3"
  local tool="$4"
  local tests_dir="$5"

  if [ "$tool" == "developer" ]; then
    local tmp_dir=""
    tmp_dir=$(_checkout "$pid" "$bid" "b");
    if [ $? -ne 0 ]; then
      echo "[ERROR] Checkout of the $pid-${bid}b version has failed!" >&2
      rm -rf "$tmp_dir"
      return 1
    fi

    local unit_tests_file="$tmp_dir/unit_tests.txt"
    >"$unit_tests_file" || die "[ERROR] Cannot write to $unit_tests_file!"
    _collect_list_of_unit_tests "$pid" "$bid" "$tmp_dir" "$unit_tests_file"
    if [ $? -ne 0 ]; then
      echo "[ERROR] Collection of unit test cases of the $pid-${bid}b version has failed!" >&2
      rm -rf "$tmp_dir"
      return 1
    fi

    local classes_to_debug_file="$tmp_dir/classes_to_debug.txt"
    >"$classes_to_debug_file" || die "[ERROR] Cannot write to $classes_to_debug_file!"
    _collect_list_of_likely_faulty_classes "$pid" "$bid" "$tmp_dir" "$classes_to_debug_file"
    if [ $? -ne 0 ]; then
      echo "[ERROR] Collection of likely faulty classes of the $pid-${bid}b version has failed!" >&2
      rm -rf "$tmp_dir"
      return 1
    fi
    local classes_to_debug=$(cat "$classes_to_debug_file")

    test_classpath=$(_get_test_classpath "$tmp_dir")
    if [ $? -ne 0 ]; then
      echo "[ERROR] _get_test_classpath for $pid-${bid}b version has failed!" >&2
      return 1
    fi
    src_classes_dir=$(_get_src_classes_dir "$tmp_dir")
   
   if [ $? -ne 0 ]; then
      echo "[ERROR] _get_src_classes_dir for $pid-${bid}b version has failed!" >&2
      return 1
    fi
    
   # for Codec projects defects4j export doesnt give correct output
    if [ "$pid" == "Codec" ]; then
	src_classes_dir="$tmp_dir/target/classes"
    fi
     
    local ser_file="$tmp_dir/gzoltar.ser"

    # Some export commands might have removed some build files
    (cd "$tmp_dir" > /dev/null 2>&1 && \
       $D4J_HOME/framework/bin/defects4j compile > /dev/null 2>&1) || die "[ERROR] Failed to compile the project!"

    echo "[INFO] Start: $(date)" >&2
    (cd "$tmp_dir" > /dev/null 2>&1 && \
     java -XX:MaxPermSize=2048M -javaagent:$GZOLTAR_AGENT_JAR=destfile=$ser_file,buildlocation=$src_classes_dir,includes=$classes_to_debug,excludes="",inclnolocationclasses=false,output="FILE" \
        -cp $src_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR \
        com.gzoltar.cli.Main runTestMethods \
          --testMethods "$unit_tests_file" \
          --collectCoverage)
    if [ $? -ne 0 ]; then
      echo "[ERROR] GZoltar runTestMethods command has failed for $pid-${bid}b version!" >&2
     # rm -rf "$tmp_dir"
      return 1
    fi
    [ -s "$ser_file" ] || die "[ERROR] $ser_file does not exist or it is empty!"

    mv "$ser_file" "$data_dir/" || return 1
    ser_file="$data_dir/gzoltar.ser"

    local spectra_file="$tmp_dir/sfl/txt/spectra.csv"
    local matrix_file="$tmp_dir/sfl/txt/matrix.txt"
    local tests_file="$tmp_dir/sfl/txt/tests.csv"

    java -cp $src_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR \
      com.gzoltar.cli.Main faultLocalizationReport \
        --buildLocation "$src_classes_dir" \
        --granularity "line" \
        --inclPublicMethods \
        --inclStaticConstructors \
        --inclDeprecatedMethods \
        --dataFile "$ser_file" \
        --outputDirectory "$tmp_dir" \
        --family "sfl" \
        --formula "ochiai" \
        --metric "entropy" \
        --formatter "txt"
    if [ $? -ne 0 ]; then
      echo "[ERROR] GZoltar faultLocalizationReport command has failed for $pid-${bid}b version!" >&2
      rm -rf "$tmp_dir"
      return 1
    fi
    echo "[INFO] End: $(date)" >&2

    [ -s "$spectra_file" ] || die "[ERROR] $spectra_file does not exist or it is empty!"
    [ -s "$matrix_file" ] || die "[ERROR] $matrix_file does not exist or it is empty!"
    [ -s "$tests_file" ] || die "[ERROR] $tests_file does not exist or it is empty!"

    mv "$spectra_file" "$data_dir/" || return 1
    spectra_file="$data_dir/spectra.csv"

    mv "$matrix_file" "$data_dir/" || return 1
    matrix_file="$data_dir/matrix.txt"

    mv "$tests_file" "$data_dir/" || return 1
    tests_file="$data_dir/tests.csv"

    rm -rf "$tmp_dir"
  else
    # TODO
    echo "$tool not supported" >&2
    return 1
  fi

  if [ ! -s "$spectra_file" ]; then
    echo "Spectra file '$spectra_file' is empty or does not exist" >&2
    return 1
  fi

  if [ ! -s "$matrix_file" ]; then
    echo "Matrix file '$matrix_file' is empty or does not exist" >&2
    return 1
  fi

  if [ ! -s "$tests_file" ]; then
    echo "Tests file '$tests_file' is empty or does not exist" >&2
    return 1
  fi

  if [ ! -s "$ser_file" ]; then
    echo "Serialization file '$ser_file' is empty or does not exist" >&2
    return 1
  fi

  # Remove extension
  mv "$spectra_file" $(dirname "$spectra_file")/$(basename "$spectra_file" .csv) || return 1
  spectra_file=$(dirname "$spectra_file")/$(basename "$spectra_file" .csv)
  mv "$matrix_file" $(dirname "$matrix_file")/$(basename "$matrix_file" .txt) || return 1
  matrix_file=$(dirname "$matrix_file")/$(basename "$matrix_file" .txt)
  mv "$tests_file" $(dirname "$tests_file")/$(basename "$tests_file" .csv) || return 1
  tests_file=$(dirname "$tests_file")/$(basename "$tests_file" .csv)

  # Remove header
  tail -n +2 "$spectra_file" > "$spectra_file.tmp" && mv -f "$spectra_file.tmp" "$spectra_file" || return 1
  tail -n +2 "$tests_file" > "$tests_file.tmp" && mv -f "$tests_file.tmp" "$tests_file" || return 1

  # Backup
  cp "$spectra_file" $(dirname "$spectra_file")/.spectra || return 1

  # Remove inner class(es) names (as there is not a .java file for each one)
  sed -i -E 's/(\$\w+)\$.*#/\1#/g' "$spectra_file" || return 1

  # Remove method name of each row in the spectra file
  sed -i 's/#.*:/#/g' "$spectra_file" || return 1

  # Replace class name symbol
  sed -i 's/\$/./g' "$spectra_file" || return 1

  return 0
}

#
# Checks whether a sanity check on the coverage of each triggering test case of
# a project-bug can or cannot be performed. A sanity check on a project-bug can
# only be performed if and only if a buggy line / candidate line could be
# identified in bytecode.
#
_is_it_a_known_exception() {
  local USAGE="Usage: ${FUNCNAME[0]} <pid> <bid>"
  if [ "$#" != 2 ]; then
    echo "$USAGE" >&2
    return 1
  fi

  local pid="$1"
  local bid="$2"

  if [ "$pid" == "Closure" ] && [ "$bid" == "100" ]; then
    # there are two different ways of triggering this bug: either covering the
    # return statement (i.e., line number 146) or the lines annotated as a
    # 'fault of omission'. If a test case does not execute the return statement
    # it is impossible to cover any line annotated as a 'fault of omission'
    # because there is not a bytecode instruction for any of the candidates
    return 0
  fi

  if [ "$pid" == "Closure" ] && [ "$bid" == "103" ]; then
    # there are two faulty classes, however there is one test case that does not
    # execute any line annotated as FAULT_OMISSION, i.e., it does not execute
    # any candidate line (manually check and it is correct)
    return 0
  fi

  if [ "$pid" == "Closure" ] && [ "$bid" == "119" ]; then
    # there is not a bytecode instruction for the candidate lines
    return 0
  fi

  if [ "$pid" == "Closure" ] && [ "$bid" == "7900014" ]; then
    # there is not a bytecode instruction for the candidate lines
    return 0
  fi

  if [ "$pid" == "Math" ] && [ "$bid" == "12" ]; then
    # there is not a bytecode instruction for the buggy line or the two lines
    # annotated as a 'fault of omission'
    return 0
  fi

  if [ "$pid" == "Math" ] && [ "$bid" == "601231" ]; then
    # there is not a bytecode instruction for the candidate lines
    return 0
  fi

  if [ "$pid" == "Mockito" ] && [ "$bid" == "5" ]; then
    # the test case fails before any line could be cover/executed
    return 0
  fi

  if [ "$pid" == "Mockito" ] && [ "$bid" == "8" ]; then
    # there is not a bytecode instruction for the buggy line
    return 0
  fi

  return 1
}

