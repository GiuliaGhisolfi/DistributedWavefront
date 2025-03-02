#!/bin/bash

THREAD=2  # Thread counts to test
SIZE=2048 # Matrix sizes to test
GRANULARITY=1  # Default granularity

# Output file for results
OUTPUT_FILE="results/results_ff.csv"

# Compilation settings
SRC_DIR="src/fastflow_wavefront"  # Source code directory
COMPILER="g++"  # Compiler to use
FASTFLOW_DIR="src"  # FastFlow include directory
FLAGS="-O3 -std=c++17 -I$FASTFLOW_DIR"  # Compilation flags

############################# FARM VERSION #############################
SOURCE_FILE="ff_farm_wavefront.cpp"  # FastFlow source file
OUTPUT_BINARY="ff_farm_wavefront.exe"  # Compiled binary

# Compile the FastFlow version
echo "Compiling $SRC_DIR/$SOURCE_FILE into $SRC_DIR/$OUTPUT_BINARY..."
$COMPILER $SRC_DIR/$SOURCE_FILE $FLAGS -o $SRC_DIR/$OUTPUT_BINARY

echo "Testing farm version..."
EXECUTION_TIME=$($SRC_DIR/$OUTPUT_BINARY --matrix_size=$SIZE --threads=$THREAD --granularity=$GRANULARITY)
            
echo "EXECUTION_TIME: $EXECUTION_TIME"
#echo "$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results