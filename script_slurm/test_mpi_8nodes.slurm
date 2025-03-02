#!/bin/bash
#SBATCH --job-name=test_mpi
#SBATCH --output=outputs/output_%j.log
#SBATCH --error=outputs/error_%j.log
#SBATCH --ntasks=16
#SBATCH --partition=normal
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=2
#SBATCH --exclusive

module load mpi

echo "Start"
bash src/mpi_wavefront/test_mpi_8nodes.sh
echo "Done"