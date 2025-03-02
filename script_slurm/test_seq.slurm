#!/bin/bash
#SBATCH --job-name=test_seq
#SBATCH --output=outputs/output_%j.log
#SBATCH --error=outputs/error_%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=31
#SBATCH --partition=normal

echo "Start"
bash src/sequential_wavefront/test_sequential.sh
echo "Done"