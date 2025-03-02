#!/bin/bash
#SBATCH --job-name=test_mpi
#SBATCH --output=outputs/output_%j.log
#SBATCH --error=outputs/error_%j.log
#SBATCH --ntasks=16
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive

module load mpi

echo "Start"
bash src/mpi_wavefront/test_mpi.sh
echo "Done"