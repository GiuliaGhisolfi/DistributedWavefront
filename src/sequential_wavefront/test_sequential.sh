#!/bin/bash

# Main parameters
MACHINE="spmcluster" # Name of the machine where tests are executed
VERSION="sequential"  # Version name
THREAD=1  # Fixed to 1 for sequential execution
GRANULARITY=0 # Not applicable for the sequential version
REPEATS=1 # Number of repetitions for each test

# Output file for results
OUTPUT_FILE="results/test_sequential.csv"

# Initialize the CSV file if it doesn't exist
if [ ! -f $OUTPUT_FILE ]; then
    echo "machine,version,threads,granularity,matrix_size,repeat,execution_time" > $OUTPUT_FILE
fi

# Compilation settings
SRC_DIR="src/sequential_wavefront"  # Source code directory
COMPILER="g++"  # Compiler to use
FASTFLOW_DIR="src"  # FastFlow include directory
FLAGS="-O3 -std=c++17 -I$FASTFLOW_DIR"  # Compilation flags

SOURCE_FILE="sequential_wavefront_comp.cpp"  # FastFlow source file
OUTPUT_BINARY="sequential_wavefront_comp.exe"  # Compiled binary

# Compile the Sequential version
echo "Compiling $SRC_DIR/$SOURCE_FILE into $SRC_DIR/$OUTPUT_BINARY..."
$COMPILER $SRC_DIR/$SOURCE_FILE $FLAGS -o $SRC_DIR/$OUTPUT_BINARY

# Tests: problem size increases with thread count
echo "Testing..."
THREADS=(1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30)
for T in "${THREADS[@]}"; do
    SIZE=128  # Initial problem size
    SIZE=$(($SIZE * $T))  # Increase the problem size with the thread count
    for REPEAT in $(seq $REPEATS); do
        # Capture the execution time by running the program
        EXECUTION_TIME=$($SRC_DIR/$OUTPUT_BINARY --matrix_size=$SIZE)
    
        echo "$MACHINE,$VERSION,$THREAD,$GRANULARITY,$SIZE,$REPEAT,$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
    done
done

for SIZE in 3072 3584 4096 4608 5120 5632 6144 6656 7168 7680 8192; do
    for REPEAT in $(seq $REPEATS); do
        # Capture the execution time by running the program
        EXECUTION_TIME=$($SRC_DIR/$OUTPUT_BINARY --matrix_size=$SIZE)
    
        echo "$MACHINE,$VERSION,$THREAD,$GRANULARITY,$SIZE,$REPEAT,$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
    done
done

echo "Tests completed. Results saved to $OUTPUT_FILE."