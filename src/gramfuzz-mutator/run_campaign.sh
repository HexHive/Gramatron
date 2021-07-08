#!/bin/bash

# This script runs a campaign using Gramatron
# Usage: ./run_campaign.sh <automaton_file> <output> <runcmd>

 if [ ! "$#" -eq 3 ]; then
  echo "Usage: $0 <automaton_file> <output> <runcmd>"
  exit 1
 fi

AUTOMATON=$1
OUTPUT_DIR=$2
RUNCMD=$3

ROOTDIR="/root/gramatron_src"
LIBRARY_LOC="$ROOTDIR/afl-gf/custom_mutators/gramfuzz/gramfuzz-mutator.so"
FUZZ_MAIN="$ROOTDIR/afl-gf/afl-fuzz"

CORPUS_SIZE=100 # The initial number of inputs that will be generated as seed inputs
INPUT_DIR="/tmp/inputs"
rm -rf $INPUT_DIR && mkdir -p $INPUT_DIR

# Create placeholder directory for seed inputs
for i in `seq -w 1 $CORPUS_SIZE`
do
    echo "a" > $INPUT_DIR/$i
done

# Setup enviromental variables
export AFL_DISABLE_TRIM=1
export AFL_CUSTOM_MUTATOR_ONLY=1
export AFL_CUSTOM_MUTATOR_LIBRARY=$LIBRARY_LOC

$FUZZ_MAIN -m none -a $AUTOMATON -i $INPUT_DIR -o $OUTPUT_DIR -- $RUNCMD
