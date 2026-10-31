# Storage and transfers

Reviewed: **2026-10-31**. Resolve the real project ID and destination in a **Marlowe shell** first.

| Location | Use | Persistence |
| --- | --- | --- |
| `/users/SUNET_ID` (`$HOME`) | Small code/configuration | 32 GB; daily backup |
| `/projects/PROJECT_ID` | Shared code, reusable environments, retained results | Allocation-specific quota; daily backup |
| `/scratch/PROJECT_ID` | Active datasets, caches, working checkpoints | Shared Lustre across nodes; no backup/replication; may be purged |
| `/local_scratch/$USER.$SLURM_JOBID` | Temporary heavy I/O inside a job | Node-local; erased at job end |

The documented scratch default is 10 TB per project; verify the actual quota. Do not assume a purge period or Sherlock's environment variables. `/projects` is automounted: `cd /projects/PROJECT_ID` directly even when its parent listing appears empty.

**Marlowe shell, after replacing `PROJECT_ID`:**

```bash
module load marlowe-scripts
storage-quota /scratch/PROJECT_ID
storage-quota /projects/PROJECT_ID
```

Inspect bytes and inodes. This helper does not cover home; `du -sh ~` estimates home usage rather than reporting its quota. Avoid whole-filesystem recursive scans. For inode pressure, [consolidate datasets](https://marlowe-research.stanford.edu/documentation/getting-started/consolidating-data/) into suitable tar/WebDataset shards, HDF5, or larger array stores. Run substantial repacking inside a job; validate the new dataset before removing originals under the user's authorized scope.

## Small and medium transfers

Create the resolved destination through the login connection. Then **locally**, using the authenticated alias:

```bash
rsync -av --partial --progress --dry-run -e 'ssh -o BatchMode=yes' \
  ./project/ marlowe:/scratch/PROJECT_ID/RUN/
```

After inspecting the preview, remove `--dry-run` to perform an authorized copy. The source's trailing slash copies its contents. Rsync may overwrite files; do not add `--delete` unless requested synchronization includes deletion. For retrieval, reverse source/destination and use the actual results path. Use explicit remote paths; local `$HOME` is not Marlowe home. For paths with spaces, use a correctly quoted SFTP session or verify rsync argument-protection support on both ends.

## Large transfers

Use [Globus](https://app.globus.org/) with Stanford sign-in. Discover the Marlowe home, scratch, or project collection and its current authorization; do not invent a DTN SSH hostname or copy Sherlock's DTN. In the **Marlowe /projects directories** collection, enter `/PROJECT_ID` manually to trigger its automount. Collection paths may be relative to their exported root, unlike SSH absolute paths.

Use an existing configured rclone remote for cloud transfers when appropriate. Check actual destination access, retention, and backup coverage before archiving to Oak or another service. Preserve irreplaceable results on a persistent destination; verify copies before cleanup.

Sources: [Filesystems](https://marlowe-research.stanford.edu/documentation/getting-started/filesystems/), [Globus](https://marlowe-research.stanford.edu/documentation/getting-started/globus/).
