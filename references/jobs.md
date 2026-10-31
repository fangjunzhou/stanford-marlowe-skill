# Slurm jobs and accounts

Reviewed: **2026-10-31**. Commands run in a **Marlowe shell**, directly or through the authenticated login connection.

## Discover the account and partition together

```bash
sacctmgr show assoc user="$USER" format=Account%30,QOS
sinfo -o '%P %a %l %D %G'
scontrol show partition preempt
sacctmgr show qos normal format=Name,MaxTRESPerAccount
```

Use an exact association, including its allocation suffix. `PROJECT_ID` is an identifier such as `m123456`; it is not the full Slurm account or its suffix.

| Account pattern | QOS | Partition | Meaning |
| --- | --- | --- | --- |
| `marlowe-PROJECT_ID` | `normal` | `preempt` | Basic Access; opportunistic and restartable |
| `marlowe-PROJECT_ID-pmNN` or `-free` | `medium` | `batch` | Allocated GPU hours |
| `marlowe-PROJECT_ID-plNN` | `large` | `hero`, also `preempt` | Allocation charged even on `preempt` |

Never assume the suffix is `01`. A `-pmNN` or `-free` account cannot use `preempt`; prefer the unsuffixed Basic Access account for opportunistic work. Check entitlement before selecting `hero`. The reviewed guide lists batch limits of 16 nodes/48 hours and hero limits of 31 nodes/30 days. Query current partition and QOS limits, especially the changing `preempt` time and per-project GPU cap.

For memory defaults inspect the selected partition's `DefMemPerCPU`. `MaxMemPerCPU` is a ceiling, not a default. Choose explicit CPU, host RAM, GPU, and time requests from the workload. Host RAM requests do not increase GPU VRAM.

## Interactive or batch

For a short GPU check, from a **login shell with a persistent terminal**, replace the account and verify the requested duration fits current limits:

```bash
srun --account=YOUR_BASIC_ACCOUNT --partition=preempt \
  --nodes=1 --ntasks=1 --gpus=1 --cpus-per-task=2 \
  --mem=8G --time=00:10:00 --pty bash
```

This creates an allocation and a compute shell. `salloc` alone grants resources but does not establish that the current shell moved onto a compute node; launch a step with `srun`. Reattach to a still-running job with `srun --jobid=JOB_ID --overlap --pty bash`. Use `--overlap` for an intentional diagnostic attachment, not to oversubscribe routine workload steps.

Use batch jobs for unattended work or tools unable to hold an interactive session. Start with [preempt](../assets/preempt-gpu.sbatch), [batch](../assets/batch-gpu.sbatch), [array](../assets/array-gpu.sbatch), or [Apptainer](../assets/apptainer-gpu.sbatch). Replace `YOUR_SLURM_ACCOUNT` with the exact association and adjust resources and application setup. Visibility checks are not training workloads.

**Marlowe shell, in the chosen `/scratch/PROJECT_ID/RUN` directory:**

```bash
mkdir -p logs
bash -n job.sbatch
sbatch --test-only job.sbatch
sbatch --parsable job.sbatch
```

Only perform the last command when submission is in scope. `--test-only` checks scheduler acceptance without submitting; it cannot verify the application. Slurm opens log paths before the script executes, so create `logs/` before submission. `#SBATCH` lines must precede executable statements and do not expand shell variables. Use resolved working/log paths or submit from the intended directory. Preserve an explicit `--chdir` choice instead of unconditionally returning to `SLURM_SUBMIT_DIR`.

## Monitor and account

Capture the returned job ID, removing any `;cluster` suffix for subsequent queries:

```bash
squeue --me
squeue -j JOB_ID -o '%.18i %.12P %.24j %.10T %.10M %R'
scontrol show job JOB_ID
sacct -j JOB_ID --format=JobID,State,ExitCode,Elapsed,AllocTRES,MaxRSS
```

Inspect pending reasons before changing a request; `squeue --start -j JOB_ID` is only an estimate. Queue absence does not prove success: check accounting, step rows, bounded logs, and expected outputs. Accounting can lag. After an uncertain/disconnected submission, inspect jobs and logs before retrying. Cancel only the intended verified job with `scancel JOB_ID` when cancellation is authorized.

For arrays, map each `SLURM_ARRAY_TASK_ID` to a real input, isolate outputs/checkpoints, and bound concurrency to project limits. For `preempt`, implement periodic save and startup reload using [checkpoints](checkpoints.md); requeue restarts the script, not process memory.

Report usage with the **actual suffixed account** and known billing-cycle start:

```bash
sreport cluster UserUtilizationByAccount -T gres/gpu \
  Start=CYCLE_START End=now Account=YOUR_ALLOCATION_ACCOUNT -t hours
```

This reports consumed hours, not remaining budget by itself. Obtain the allocation total and correct cycle before calculating a remainder; consult the current recharge page for prices.

Sources: [Marlowe Slurm](https://marlowe-research.stanford.edu/documentation/slurm/), [sbatch](https://slurm.schedmd.com/sbatch.html), [srun](https://slurm.schedmd.com/srun.html).
