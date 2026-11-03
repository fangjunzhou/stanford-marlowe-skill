#!/bin/bash
#SBATCH --job-name=marlowe-array
#SBATCH --account=YOUR_SLURM_ACCOUNT
#SBATCH --partition=preempt
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gpus=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=00:05:00
#SBATCH --array=0-3%2
#SBATCH --requeue
#SBATCH --output=logs/%x-%A_%a.out
#SBATCH --error=logs/%x-%A_%a.err

# Replace account with an exact Basic Access account; create logs/ first.
# Four smoke items, at most two concurrent: check the project's GPU cap.
# For real workloads, set the range from the data shard count and tune the
# concurrency cap and per-shard resources; prefer many small independent jobs.
# For allocated batch hours, change account AND partition together.
set -euo pipefail
: "${SLURM_JOB_ID:?Submit through sbatch on Marlowe}"
: "${SLURM_ARRAY_TASK_ID:?Submit as a Slurm array}"
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
printf 'job=%s item=%s directory=%s\n' "$SLURM_JOB_ID" "$SLURM_ARRAY_TASK_ID" "$PWD"

# Replace with the manifest-selected application command for this data shard.
# Process only this shard's inputs. Give each shard
# separate outputs/checkpoints and implement startup resume for preemption.
srun --ntasks=1 nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
