#!/bin/bash
#SBATCH --job-name=marlowe-preempt
#SBATCH --account=YOUR_SLURM_ACCOUNT
#SBATCH --partition=preempt
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:05:00
#SBATCH --requeue
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# Replace account with the exact unsuffixed Basic Access account.
# Check current preempt limits. Submit from /scratch/PROJECT_ID/RUN
# after creating logs/. Resources here are illustrative smoke-test sizes.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit through sbatch on Marlowe}"
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
printf 'job=%s directory=%s\n' "$SLURM_JOB_ID" "$PWD"

# Replace with the environment and workload. For CUDA applications,
# module load mps before launch to isolate MPS paths if needed.
# Training must save periodically and load completed checkpoints on restart.
# Requeue alone does not resume application state.
srun --ntasks=1 nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
