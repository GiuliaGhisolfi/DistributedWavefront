#!/bin/bash

SIZE=2048

# Output file for results
OUTPUT_FILE="results/results_seq.csv"

# Compilation settings
SRC_DIR="src/sequential_wavefront"  # Source code directory
COMPILER="g++"  # Compiler to use
FASTFLOW_DIR="src"  # FastFlow include directory
FLAGS="-O3 -std=c++17 -I$FASTFLOW_DIR"  # Compilation flags

SOURCE_FILE="sequential_wavefront_comp.cpp"  # FastFlow source file
OUTPUT_BINARY="sequential_wavefront_comp.exe"  # Compiled binary

# Compile
$COMPILER $SRC_DIR/$SOURCE_FILE $FLAGS -o $SRC_DIR/$OUTPUT_BINARY

EXECUTION_TIME=$($SRC_DIR/$OUTPUT_BINARY --matrix_size=$SIZE)
# src/sequential_wavefront/sequential_wavefront_comp.exe --matrix_size=64

echo "EXECUTION_TIME: $EXECUTION_TIME"
#echo "$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
