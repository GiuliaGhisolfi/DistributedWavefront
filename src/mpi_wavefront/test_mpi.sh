#!/bin/bash
# to compile: mpic++ -o src/wavefront_mpi_comp src/mpi_wavefront_comp.cpp

NUM_PROCESSES=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)
REPEATS=3 # Number of repetitions for each test

# Set the executable name
EXECUTABLE="src/mpi_wavefront/mpi_wavefront"

# Output file for results
OUTPUT_FILE="results/test_mpi_1nodes.csv"

# Initialize the CSV file if it doesn't exist
if [ ! -f $OUTPUT_FILE ]; then
    echo "num_processes,matrix_size,repeat,execution_time" > $OUTPUT_FILE
fi

# Compile the MPI program
echo "Compiling MPI program..."
mpic++ -O3 -march=native -ffast-math -fopenmp -o $EXECUTABLE src/mpi_wavefront/mpi_wavefront_comp.cpp

# Strong scalability tests: fixed problem size, varyng process counts
MATRIX_SIZE=2048
for NUM_PROC in "${NUM_PROCESSES[@]}"; do
    echo "Running MPI program with $NUM_PROC processes and matrix size $MATRIX_SIZE..."
    for REPEAT in $(seq $REPEATS); do
        EXECUTION_TIME=$(mpirun -np $NUM_PROC ./$EXECUTABLE $MATRIX_SIZE)
        echo "$NUM_PROC,$MATRIX_SIZE,$REPEAT,$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
    done
done

# Weak scalability tests: problem size increases with process count
for NUM_PROC in "${NUM_PROCESSES[@]}"; do
    MATRIX_SIZE=$((NUM_PROC * 512))
    echo "Running MPI program with $NUM_PROC processes and matrix size $MATRIX_SIZE..."
    for REPEAT in $(seq $REPEATS); do
        EXECUTION_TIME=$(mpirun -np $NUM_PROC ./$EXECUTABLE $MATRIX_SIZE)
        echo "$NUM_PROC,$MATRIX_SIZE,$REPEAT,$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
    done
done

# Single process tests: varying problem size
NUM_PROC_REAL=1
for NUM_PROC in "${NUM_PROCESSES[@]}"; do
    MATRIX_SIZE=$((NUM_PROC * 512))
    echo "Running MPI program with 1 processes and matrix size $MATRIX_SIZE..."
    for REPEAT in $(seq $REPEATS); do
        EXECUTION_TIME=$(mpirun -np $NUM_PROC_REAL ./$EXECUTABLE $MATRIX_SIZE)
        echo "$NUM_PROC_REAL,$MATRIX_SIZE,$REPEAT,$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
    done
done

# Check the exit status of the program
if [ $? -eq 0 ]; then
    echo "Test completed successfully."
else
    echo "Test failed."
    exit 1
fi
