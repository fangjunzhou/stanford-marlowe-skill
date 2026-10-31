# GPU and distributed workloads

Reviewed: **2026-10-31**. Run GPU diagnostics inside the corresponding **allocated compute job**.

The reviewed hardware is 31 DGX H100 nodes, each with eight H100 80 GB GPUs and 2 TB host RAM, connected by 400 Gb InfiniBand. These are physical specifications, not an entitlement to a whole node. Query actual allocation and device visibility.

## Verify allocation and framework

Request GPUs explicitly with `--gpus=N`, `--gpus-per-node=N`, or an appropriate task-based request. Partition selection alone does not grant GPUs. A single-node smoke check can use [the preempt template](../assets/preempt-gpu.sbatch).

Inside the job:

```bash
printf 'visible=%s allocated=%s\n' "${CUDA_VISIBLE_DEVICES:-}" "${SLURM_JOB_GPUS:-}"
nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
```

Load the actual project environment and test a small real CUDA operation. For an existing PyTorch environment:

```bash
python - <<'PY'
import torch
print('torch:', torch.__version__, 'CUDA build:', torch.version.cuda)
assert torch.cuda.is_available(), 'CUDA initialization failed'
x = torch.ones(8, device='cuda')
assert x.sum().item() == 8
print(torch.cuda.get_device_name(0))
PY
```

Successful `nvidia-smi` alone does not prove framework compatibility. Respect Slurm's device mask. Device OOM calls for model/batch/precision changes or a supported distributed strategy; increasing host `--mem` does not add VRAM.

For `CUDA_ERROR_MPS_CONNECTION_FAILED`, load `mps` **inside the job before CUDA starts**. It isolates MPS temporary paths by job; do not delete another job's `/tmp/nvidia-mps`. Container environments may need the resulting variables forwarded explicitly.

## Distributed launch

Keep the project's supported launch model. Decide whether Slurm launches one process per GPU, or one launcher per node that spawns GPU workers. Match tasks, GPU binding, CPU workers, world size, rendezvous host/port, and node rank to that model. Do not combine per-GPU Slurm tasks with a launcher spawning the same workers again. Use a small multi-node check before a large allocation.

For NCCL failures, enable `NCCL_DEBUG=INFO` and inspect the `srun` step logs. Leave `NCCL_SOCKET_IFNAME` unset for automatic selection unless live evidence requires a specific interface: Marlowe has **no `ib0`**. Look for `NET/IB` in logs to check the data path; the socket-interface setting controls bootstrap, not whether data uses InfiniBand.

For the documented Open MPI UCX/component failure, inspect the environment first. The FAQ's targeted repair loads `nvhpc` followed by `gcc/64` to restore fabric libraries; do not make this a universal module purge for unrelated jobs. Load `slurm` again if a deliberate purge removed it. NVHPC math libraries are under `$NVHPC_ROOT/math_libs`; inspect versioned subdirectories before extending linker paths.

Sources: [Hardware](https://marlowe-research.stanford.edu/documentation/specs/), [MPS, NCCL, and MPI diagnostics](https://marlowe-research.stanford.edu/documentation/faq/#4-gpu-distributed-training).
