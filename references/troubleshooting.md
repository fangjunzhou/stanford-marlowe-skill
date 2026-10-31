# Troubleshooting

Reviewed: **2026-10-31**. Capture the exact command/error, execution location, affected path, and job ID. Prefer focused diagnosis over broad changes.

| Symptom | Inspect and act |
| --- | --- |
| Connection closes before login | Confirm activation; repeated SSH attempts cannot activate an account. |
| Duo succeeds, then session closes | Check membership in `marlowe-users` with support. |
| Cached SSH no longer works | Check `ssh -O check marlowe` locally; return interactive authentication to the user if needed. |
| Account/QOS/partition rejected | Discover exact associations; see [jobs](jobs.md). Do not guess suffixes. |
| Job pending or node `plnd` | Read `%R` in `squeue` and `scontrol show job`; `plnd` indicates a planned reservation. |
| Job repeatedly restarts | Inspect preemption/requeue and [checkpoint recovery](checkpoints.md). |
| GPU absent, device OOM, MPS, NCCL, or UCX errors | Use [GPU diagnostics](gpu.md) in the allocation and check the application's environment. |
| `nvcc` absent | Inspect/load `nvhpc`; it is not a default module. |
| Container cannot see a module library | Inspect binds and library paths; see [environments](environments.md). |
| Project directory missing | Access its full `/projects/PROJECT_ID` path to trigger automount. |
| Write fails despite free bytes | Check inode quota and permissions as well as bytes using [storage](storage-and-transfers.md). |
| Project quota stays high after deletion | Snapshot retention can delay release; consult support rather than deleting unrelated data. |
| No job logs | Verify the job started, working directory, log paths, and pre-created log parents. |
| Logs stop updating | Check state and application progress; use unbuffered Python when useful, without assuming a hang. |
| Job disappears from queue | Use accounting, step exit codes, logs, and expected results to establish its outcome. |

**Marlowe shell, replace the numeric job ID:**

```bash
scontrol show job JOB_ID
sacct -j JOB_ID --format=JobID,State,ExitCode,Elapsed,AllocTRES,MaxRSS
```

Completed jobs may have left `scontrol`; accounting may lag. Inspect bounded stdout/stderr and the actual submitted script, including environment and command-line overrides. Do not automatically cancel jobs, remove checkpoints, reinstall software, or resubmit duplicate work.

For unresolved issues, prepare a support draft with “Marlowe” in the subject, user-supplied SUNet ID, node/job ID, relevant paths, script/command, exact error, and checks performed. The documented first route is Stanford Slack `#marlowe-researchers`; `srcc-support@stanford.edu` is suitable for technical/private details and `marlowe-info@stanford.edu` for allocations/access policy. Contact or post only when the user requests it.

Sources: [FAQ](https://marlowe-research.stanford.edu/documentation/faq/), [Help and support](https://marlowe-research.stanford.edu/documentation/help-and-support/).
