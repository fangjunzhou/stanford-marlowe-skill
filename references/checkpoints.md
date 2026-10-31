# Checkpoints and preemption

Reviewed: **2026-10-31**. `preempt` jobs may stop whenever higher-priority work needs their nodes. Requeue starts the script over; it does not restore process memory.

Use a stable run-specific directory in `/scratch/PROJECT_ID/RUN/ckpts` for working checkpoints. Shared scratch is visible from every login and compute node, so a restarted job on a different node can read it directly. Checkpoints kept only in `/local_scratch/$USER.$SLURM_JOBID` disappear at job end; copy them to shared storage periodically, not only in an exit trap.

Adapt the application's existing save/resume mechanism:

- Save model, optimizer, step, and any scheduler, scaler, RNG, sampler, or data position needed for correct recovery.
- Write to a temporary file in the checkpoint directory and rename on the same filesystem after completion. Select completed, valid checkpoints on startup; do not load partial files.
- Give each run and array element a distinct path. In distributed training, coordinate rank writes and restore using the framework's supported checkpoint format.
- Make startup and output handling repeatable: requeue should not destroy previous progress or append duplicate final records.

`--requeue` in [the preempt template](../assets/preempt-gpu.sbatch) makes eligibility explicit; it does not implement checkpointing. Test save and resume on a short allocated run before relying on recovery for long training. Do not assume an advance preemption signal provides enough time for a final save.

Keep frequent checkpoint churn on scratch. Copy selected completed checkpoints to `/projects/PROJECT_ID` or an authorized archive for retention. `/projects` snapshots may keep deleted checkpoint data charged to quota temporarily. Verify the retained copy before removing working files.

Source: [Saving checkpoints](https://marlowe-research.stanford.edu/documentation/getting-started/saving-checkpoints/).
