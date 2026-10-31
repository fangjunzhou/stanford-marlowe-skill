# Remote development, notebooks, and agents

Reviewed: **2026-10-31**. Access routes and compute allocations are separate decisions.

## Browser applications

[Open OnDemand](https://ood.marlowe.stanford.edu/) provides Jupyter Lab, marimo, and Code Server. Choose **Interactive Apps**, select the app, enter a matching account and partition, request resources, wait for allocation, and connect. Use [jobs](jobs.md) for account selection. Submission does not mean the app is ready.

The FAQ currently lists Code Server limits of four CPUs, 12 GB host RAM, and eight hours, without a GPU request option. Check the current form. Use the appropriate GPU notebook app or a separate GPU Slurm job for GPU work instead of assuming an editor session has accelerators. Open OnDemand is the supported browser editor; installing your own editor backend on a login node is blocked.

VS Code/Cursor **Remote - SSH** is unsupported. For local editors, use [SSHFS](access.md); for remote VS Code, use Code Server. Verify extension availability in that app rather than assuming full desktop extension compatibility.

## Services and tunnels

Self-managed Code Server or inference services belong inside a compute allocation. Ordinary SSH port forwarding is permitted; editor web tunnels, SSHX, Claude Remote Control/Server, Tailscale, and ZeroTier bypassing the authenticated Marlowe entry path are prohibited.

When a service is requested, determine its live allocated node, listen address, port, and job lifetime first. A service listening on the compute node's network interface can be reached with a **local** forward through the authenticated login alias:

```bash
ssh -o BatchMode=yes -N -L 127.0.0.1:LOCAL_PORT:COMPUTE_NODE:SERVICE_PORT marlowe
```

Replace all three placeholders and retain application authentication. This forward is opened from the login node to the compute node; a service bound only to compute-node loopback needs a tunnel terminating on that compute node instead. Do not claim a login-host forward can reach its loopback service. Verify the job still runs before reconnecting; compute-node SSH is allowed while the user has a job there.

## Agents running on Marlowe

For substantial agent work, use an existing adequate compute allocation or obtain one before starting builds/tests/process-heavy activity. Verify hostname and job state. With one-shot tools, use batch work or an explicit user-terminal handoff; do not claim the agent moved nodes merely because `salloc` returned an ID.

Keep the skill and reusable software on persistent shared storage so compute nodes can read them. Discover the chosen agent's available executable/module rather than assuming Sherlock's agent modules exist. Follow the selected vendor's current authentication/resume instructions; no credential belongs in this skill or a submitted script. Preserve the user's provider choice and data-handling requirements.

Record job ID, node, and project directory. `tmux` on one login node will not appear on another; pinned SSH aliases help reconnect consistently. A terminal or agent inside a compute allocation ends when that allocation ends. Submitted independent batch jobs have their own lifetimes.

Sources: [Open OnDemand](https://marlowe-research.stanford.edu/documentation/openondemand/), [remote development FAQ](https://marlowe-research.stanford.edu/documentation/faq/#5-remote-development), [Marlowe operating restrictions](https://marlowe-research.stanford.edu/documentation/violations/).
