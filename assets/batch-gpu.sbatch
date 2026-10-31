#!/bin/bash
#SBATCH --job-name=marlowe-batch
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

# Replace account with the exact -pmNN or -free account from associations.
# This consumes allocated GPU hours. Submit from /scratch/PROJECT_ID/RUN
# after creating logs/. Adjust resources and initialize the real environment.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit through sbatch on Marlowe}"
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
printf 'job=%s directory=%s\n' "$SLURM_JOB_ID" "$PWD"

# GPU visibility only; replace with the project's validated application.
srun --ntasks=1 nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
