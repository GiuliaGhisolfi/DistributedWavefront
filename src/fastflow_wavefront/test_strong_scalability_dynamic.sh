#!/bin/bash

# Main parameters
MACHINE="spmcluster" # Name of the machine where tests are executed
THREADS=(1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30)  # Thread counts to test
GRANULARITIES=(1 16 32 64 128)  # Default granularity
SIZE=2048  # Matrix size
REPEATS=3 # Number of repetitions for each test

SOURCE_FILE="ff_wavefront_dynamic.cpp"  # Source file
OUTPUT_BINARY="ff_wavefront_dynamic.exe"  # Compiled binary
VERSION="ff_dynamic"  # Version name

# Compilation settings
SRC_DIR="src/fastflow_wavefront"  # Source code directory
COMPILER="g++"  # Compiler to use
FASTFLOW_DIR="src"  # FastFlow include directory
FLAGS="-O3 -std=c++17 -I$FASTFLOW_DIR"  # Compilation flags

# Compile the FastFlow version
echo "Compiling $SRC_DIR/$SOURCE_FILE into $SRC_DIR/$OUTPUT_BINARY..."
$COMPILER $SRC_DIR/$SOURCE_FILE $FLAGS -o $SRC_DIR/$OUTPUT_BINARY

# Strong scalability tests: fixed problem size, varying thread counts
echo "Testing strong scalability..."
for GRANULARITY in "${GRANULARITIES[@]}"; do
    # Output file for results
    OUTPUT_FILE="results/strong_scalability_dynamic_g${GRANULARITY}.csv"

    # Initialize the CSV file if it doesn't exist
    if [ ! -f $OUTPUT_FILE ]; then
        echo "machine,version,threads,granularity,matrix_size,repeat,execution_time" > $OUTPUT_FILE
    fi

    for THREAD in "${THREADS[@]}"; do
        for REPEAT in $(seq $REPEATS); do
            # Capture the execution time by running the program
            EXECUTION_TIME=$($SRC_DIR/$OUTPUT_BINARY --matrix_size=$SIZE --threads=$THREAD --granularity=$GRANULARITY)
            
            echo "$MACHINE,$VERSION,$THREAD,$GRANULARITY,$SIZE,$REPEAT,$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
        done
    done
done

echo "Tests completed. Results saved to $OUTPUT_FILE."