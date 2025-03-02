#!/bin/bash
#SBATCH --job-name=test_ff_static
#SBATCH --output=outputs/output_%j.log
#SBATCH --error=outputs/error_%j.log
#SBATCH --nodes=1
#SBATCH --ntasks=31
#SBATCH --partition=normal

echo "Start"
bash src/fastflow_wavefront/test_strong_scalability_static.sh
bash src/fastflow_wavefront/test_weak_scalability_static.sh
echo "Done"