# Software and containers

Reviewed: **2026-10-31**. Use lightweight discovery on a login node; put sustained installation, compilation, and application tests inside an allocation.

## Modules and Python

```bash
module avail
module list
module show conda
module show nvhpc
```

Use the actual installed versions and module help; do not assume Sherlock's Lmod helpers exist. The software guide lists `slurm` and `gcc/13.1.0` as defaults, not a future inventory. Pin the selected versions in reproducible jobs and initialize them in each job shell. Honor existing dependency files and container choices.

Marlowe provides Mamba via `module load conda`. For a new project environment, choose a user-specific persistent prefix outside the small home quota:

```bash
module load conda
env_dir="/projects/PROJECT_ID/$USER/envs/PROJECT_NAME"
mamba env create --prefix "$env_dir" --file environment.yml
```

Replace the project/name and use the real environment file. Inspect an existing prefix before modifying it. The official interactive activation setup uses `mamba init`, logout, and login; it changes shell startup files, so use it when relevant rather than rewriting startup configuration for every job. Batch jobs can use `conda run --no-capture-output --prefix "$env_dir" python -u main.py` after loading the module. Use the selected environment's interpreter for pip and imports; do not copy workstation environments.

## CUDA tools

`module load nvhpc` is Marlowe's preferred CUDA toolchain and supplies `nvcc`, but changes `CC`/`CXX`. `cudatoolkit` additionally sets `CUDA_HOME`. NVHPC does not include cuDNN; load a discovered compatible cuDNN module only if the application needs it. Framework packages and containers can bundle their own CUDA/cuDNN, so do not automatically layer host libraries onto them.

## Apptainer

Apptainer is directly available; Docker execution is unsupported. Put caches outside home, with user-specific directories in shared projects:

```bash
export APPTAINER_CACHEDIR="/scratch/PROJECT_ID/$USER/cache/apptainer"
mkdir -p "$APPTAINER_CACHEDIR"
apptainer pull framework.sif docker://REGISTRY/IMAGE:SELECTED_TAG
```

Choose a real compatible image/tag; retain the chosen version or digest. Use [the container job](../assets/apptainer-gpu.sbatch) for GPU execution with `--nv` and explicit project/scratch binds. The container's own environment should provide its application dependencies.

For a container intentionally using **host module libraries**, inspect `module show`, bind the needed `/cm/shared/apps` and/or `/marlowe/apps` paths, and explicitly pass the needed library path. Apptainer replaces `LD_LIBRARY_PATH` internally. **Do not inject host cuDNN into PyTorch/NGC images that already include it**; incompatible versions can prevent startup.

## NGC and NIM

Use [the NIM guide](https://marlowe-research.stanford.edu/documentation/ngc-nims/) for registry authentication and model-specific cache binds. Let the user supply credentials through a private runtime environment or interactive registry login. NGC's Docker username is the literal `$oauthtoken`. Keep keys out of chat, job scripts, command logs, and versioned files. Avoid replacing existing cache directories with symlinks without inspecting them; configure per-project cache paths instead.

Size GPUs for the chosen model rather than inheriting the guide's eight-GPU example. Run inference services in a Slurm compute allocation and use the access route in [remote development](remote-development.md).

Sources: [Software](https://marlowe-research.stanford.edu/documentation/software/), [Conda](https://marlowe-research.stanford.edu/documentation/software/conda/), [NVHPC](https://marlowe-research.stanford.edu/documentation/software/nvhpc/), [CUDA toolkit](https://marlowe-research.stanford.edu/documentation/software/cudatoolkit/), [Apptainer](https://marlowe-research.stanford.edu/documentation/software/apptainer/).
