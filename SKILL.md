---
name: marlowe
description: Connect to Stanford Marlowe HPC, transfer research files, prepare software and containers, and submit, monitor, or troubleshoot Slurm GPU jobs. Use for Marlowe accounts and partitions, H100 workloads, checkpoints, storage quotas, Open OnDemand, and local SSH or allocated compute workflows.
---

# Marlowe

Use native OpenSSH, rsync, environment modules, Apptainer, and Slurm. Read only the references relevant to the user's task. This skill works from a workstation or a Marlowe shell and supplies no custom command runner.

## Establish where commands will run

Distinguish the workstation, a Marlowe login node, and an allocated compute node. In an existing cluster shell, inspect:

```bash
hostname -f
printf 'job=%s nodes=%s\n' "${SLURM_JOB_ID:-}" "${SLURM_JOB_NODELIST:-}"
```

Verify an apparent allocation with `scontrol show job JOB_ID`; environment variables alone do not prove it is running or that this shell is on its compute node. Reuse an adequate active allocation rather than requesting another one.

- **Workstation:** establish or reuse SSH using [access](references/access.md); distinguish local paths from remote paths.
- **Login node:** edit, discover resources, submit jobs, transfer files, and do short, light setup. Put sustained builds, tests, processing, inference, and substantial agent work in Slurm allocations.
- **Allocated compute node:** stay within the assigned CPUs, host memory, GPUs, and walltime.

Label command examples by execution location. Quote remote shell programs or use quoted heredocs so cluster variables expand on Marlowe. Do not infer the SUNet ID from a workstation username, or invent the project ID or allocation suffix.

## Select the relevant workflow

| Task | Read | Starting assets |
| --- | --- | --- |
| SSH, Duo reuse, or SSHFS editing | [Access](references/access.md) | [SSH configuration](assets/ssh_config) |
| Storage selection, quotas, or file transfers | [Storage and transfers](references/storage-and-transfers.md) | rsync/scp or Globus |
| Account/partition selection, submission, monitoring, or arrays | [Jobs and accounts](references/jobs.md) | [Preempt GPU](assets/preempt-gpu.sbatch), [batch GPU](assets/batch-gpu.sbatch), [array](assets/array-gpu.sbatch) |
| Python, CUDA tools, Apptainer, or NGC | [Environments](references/environments.md) | [Container job](assets/apptainer-gpu.sbatch) |
| GPU checks, multi-GPU launches, NCCL, or MPS | [GPUs](references/gpu.md) | The project's existing launcher |
| Preemption recovery or checkpoint placement | [Checkpoints](references/checkpoints.md) | The project's save/resume implementation |
| Browser notebooks, remote editors, or agents on Marlowe | [Remote development](references/remote-development.md) | Open OnDemand or an active compute allocation |
| Failed login, job, software, or storage | [Troubleshooting](references/troubleshooting.md) | Exact error, script, and job logs |

## Essential Marlowe constraints

Every job needs a valid account and an explicit GPU request when GPUs are needed. Discover the account/partition pairing before choosing resources. `preempt` can restart a job from its script's beginning; application checkpoint loading supplies recovery.

Use `/scratch/PROJECT_ID` for active I/O, `/projects/PROJECT_ID` for persistent project material, and the job's `/local_scratch/$USER.$SLURM_JOBID` only for disposable node-local work. Scratch is not backed up. Do not import Sherlock paths, helper commands, partitions, GPU constraints, or retention periods into Marlowe.

Authentication uses SUNet password and Duo. Let the user handle credentials in their terminal; use an authenticated SSH master for subsequent agent commands. Preserve host-key checking and stop automated authentication retries on failure.

Remote access must preserve Marlowe's authenticated entry path. Use Open OnDemand, SSHFS, or ordinary authenticated SSH forwarding as appropriate. Editor web tunnels, userspace VPNs, and other services bypassing that entry path are prohibited. See [remote development](references/remote-development.md) for the documented distinctions.

Honor the user's authorization for changes, submissions, and cancellations without adding a blanket confirmation step. Diagnose-only requests do not imply permission to cancel jobs, spend a different allocation, or delete data.

## Report the observed result

For submissions, report job ID, account/partition, script and working directory, resource request, logs, and observed state. Submission acceptance does not establish workload success. For transfers, distinguish previews from completed copies. State which checks were local, scheduler-only, or actual application runs.

Reviewed against the [official Marlowe guide](https://marlowe-research.stanford.edu/documentation/) on **2026-10-31**, using the [Sherlock skill](https://github.com/fangjunzhou/stanford-sherlock-skill/tree/a4a77fc8b3e9fb2a4498341587e1f31a7b7a7ad0) as a structural reference. The legacy `docs.marlowe.stanford.edu` site redirects to this guide. Recheck policies in the official guide and use live queries for associations, limits, and module versions.
