#!/bin/bash
#SBATCH --job-name=test_mpi
#SBATCH --output=outputs/output_%j.log
#SBATCH --error=outputs/error_%j.log
#SBATCH --ntasks=4
#SBATCH --partition=normal
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --exclusive

module load mpi

echo "Start"
bash src/mpi_wavefront/test_mpi_2nodes.sh
echo "Done"