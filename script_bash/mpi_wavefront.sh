#!/bin/bash
# to compile: mpic++ -o src/wavefront_mpi_comp src/mpi_wavefront_comp.cpp
NUM_PROC=1
MATRIX_SIZE=2048

# Set the executable name
EXECUTABLE="src/mpi_wavefront/mpi_wavefront"

# Output file for results
OUTPUT_FILE="results/result.csv"

# Compile the MPI program
echo "Compiling MPI program..."
mpic++ -O3 -march=native -ffast-math -fopenmp -o $EXECUTABLE src/mpi_wavefront/mpi_wavefront_comp.cpp
# mpic++ -O3 -march=native -ffast-math -fopenmp -o src/mpi_wavefront/mpi_wavefront src/mpi_wavefront/mpi_wavefront_comp.cpp

EXECUTION_TIME=$(mpirun -np $NUM_PROC ./$EXECUTABLE $MATRIX_SIZE)
# mpirun -np 1 src/mpi_wavefront/mpi_wavefront_comp 2048

echo "EXECUTION_TIME: $EXECUTION_TIME"
#echo "$EXECUTION_TIME" >> $OUTPUT_FILE  # Save results
