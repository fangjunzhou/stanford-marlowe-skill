# Access and authenticated sessions

Reviewed: **2026-10-31**. Commands marked **local** run on the workstation. An approved, activated Marlowe account and SUNet ID are prerequisites.

## Connect and reuse authentication

The **user runs locally**:

```bash
ssh YOUR_SUNET_ID@login.marlowe.stanford.edu
```

The hostname balances among `login-01`, `login-02`, and `login-03`. Each is directly addressable as `login-0N.marlowe.stanford.edu`. Verify an unfamiliar or changed host key through a trusted Stanford source; do not disable checking or automatically erase known-host entries. Password and Duo entry belong in the user's terminal, never chat, scripts, or command arguments.

For repeated work, merge [the SSH asset](../assets/ssh_config) into local `~/.ssh/config`, replace the SUNet ID, and preserve unrelated entries. Specific entries should precede broad defaults. The `marlowe` alias pins `login-01`; `marlowe-02` and `marlowe-03` select alternatives. Use the same alias for shells, transfers, and mounts. The hashed `%C` socket name avoids long socket paths.

**Local, inspect configuration without connecting:**

```bash
ssh -G marlowe
```

Check hostname, user, and multiplexing settings. The **user then runs locally**:

```bash
ssh -MNf marlowe
```

After successful interactive authentication, the **local agent** can check reuse:

```bash
ssh -O check marlowe
ssh -o BatchMode=yes -o ConnectTimeout=15 marlowe 'hostname -f'
```

Batch mode prevents a fresh credential prompt; it does not authenticate or renew Duo. If reuse fails, inspect the error once and return authentication to the user. Do not loop failed logins. The agent and user's terminal must share access to the socket for reuse to work.

## Execute remote commands

**Local agent, lightweight cluster discovery:**

```bash
ssh -T -o BatchMode=yes marlowe 'bash -l -s' <<'MARLOWE'
hostname -f
printf 'remote home=%s\n' "$HOME"
sacctmgr show assoc user="$USER" format=Account%30,QOS
MARLOWE
```

The quoted heredoc prevents workstation variable expansion. Each SSH command starts a separate shell: `cd`, module loads, and activation do not persist into later commands. Initialize the environment in the remote command or job itself. Use `ssh -t marlowe` for an interactive terminal, then request compute resources as described in [jobs](jobs.md).

## Mount files for local editing

After the user installs a matching FUSE implementation and SSHFS client, **local**:

```bash
mkdir -p ~/mnt/marlowe
sshfs marlowe: ~/mnt/marlowe -o idmap=user
```

This mounts home. For project code, create a separate mountpoint and mount a resolved subdirectory such as `marlowe:/projects/PROJECT_ID/code`. On macOS, mounting the project root itself can fail when listing; use the needed subdirectory. Verify the mount is actually live before writing through it: SSHFS can return before mounting finishes. Unmount with `diskutil unmount MOUNTPOINT` on macOS or `umount MOUNTPOINT` on Linux.

Avoid SSHFS's `reconnect` option and unmount before laptop sleep: repeated failed reconnections can block the source IP. Unmount before `ssh -O exit marlowe`, which closes the cached connection and its channels. A submitted batch job survives losing the workstation SSH connection; check existing jobs before repeating an uncertain submission.

Sources: [Connecting, multiplexing, and SSHFS](https://marlowe-research.stanford.edu/documentation/getting-started/connecting/), [OpenSSH configuration](https://man.openbsd.org/ssh_config).
