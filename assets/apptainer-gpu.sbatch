#!/bin/bash
#SBATCH --job-name=marlowe-container
#SBATCH --account=YOUR_SLURM_ACCOUNT
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:05:00
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# Replace the exact -pmNN/-free account and both project bind paths below.
# Create logs/ before submission. Image and executable are script arguments:
# sbatch apptainer-gpu.sbatch /absolute/path/framework.sif python -u train.py
# Initialize any necessary host environment here; do not inject host cuDNN
# into a framework container that bundles its own version.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit through sbatch on Marlowe}"
if (( $# < 2 )); then
    printf 'Usage: sbatch %s IMAGE.sif COMMAND [ARG ...]\n' "$0" >&2
    exit 2
fi
image="$1"
shift
if [[ ! -r "$image" ]]; then
    printf 'Image is not readable: %s\n' "$image" >&2
    exit 2
fi
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
srun --ntasks=1 apptainer exec --nv \
    --bind /scratch/PROJECT_ID,/projects/PROJECT_ID \
    "$image" "$@"
