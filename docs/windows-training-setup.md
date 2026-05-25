# Windows Training Setup

This document describes the current known-working training environment for this repository and the fastest path to reproduce it on another Windows machine.

## Known Working Machine

- OS: Windows 10 Home, build 19045, x64
- GPU: NVIDIA GeForce RTX 5070 Ti
- NVIDIA driver: 581.29
- Python: 3.11.15
- IsaacLab upstream version file: 2.3.2
- Isaac Sim packages: 5.1.0.0
- PyTorch: 2.7.0+cu128
- Torch CUDA runtime: 12.8

## Important Boundaries

- `env_isaaclab/`, `.isaaclab_cache/`, `logs/`, and `outputs/` are local-only and are not synchronized by Git.
- The custom Ant asset USD must be rebuilt on a fresh machine because it lives under `.isaaclab_cache/`.
- This repository uses an SSH submodule for `IsaacLab/`, so the target machine must be able to access GitHub over SSH.

## Recommended Reproduction Flow

1. Install Git for Windows and configure GitHub SSH access for `git@github.com`.
2. Clone the workspace with submodules:

```powershell
git clone --recurse-submodules git@github.com:TonyXieXie/IsaacLearning.git
cd IsaacLearning
```

3. Run the workspace bootstrap:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup\init_workspace.ps1 -InstallRlGames -InstallPinnedPackages -BuildProjectAssets
```

This does four things:

- syncs and initializes the `IsaacLab/` submodule
- creates or updates the IsaacLab Python environment with `rl_games`
- aligns the Python environment with the pinned snapshot in `repro/windows/current-machine/pip-postinstall-lock.txt`
- rebuilds the custom `ant_3joint.usda` asset under `.isaaclab_cache/`

4. Verify the result:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup\verify_workspace.ps1
```

5. Start training:

```powershell
.\scripts\windows\train_ant_3joint_velocity_flat.cmd
```

## Strict Snapshot vs. Minimal Install

There are two useful setup modes:

- Minimal:
  - `.\scripts\setup\init_workspace.ps1 -InstallRlGames -BuildProjectAssets`
  - Best when you want the standard IsaacLab dependency set plus this project's assets.
- Strict:
  - `.\scripts\setup\init_workspace.ps1 -InstallRlGames -InstallPinnedPackages -BuildProjectAssets`
  - Best when you want the target machine as close as possible to the current working machine.

## Snapshot Files

The current machine snapshot is stored under:

- [`repro/windows/current-machine/metadata.json`](/D:/AI/Issac/repro/windows/current-machine/metadata.json)
- [`repro/windows/current-machine/python-version.txt`](/D:/AI/Issac/repro/windows/current-machine/python-version.txt)
- [`repro/windows/current-machine/pip-freeze-full.txt`](/D:/AI/Issac/repro/windows/current-machine/pip-freeze-full.txt)
- [`repro/windows/current-machine/pip-postinstall-lock.txt`](/D:/AI/Issac/repro/windows/current-machine/pip-postinstall-lock.txt)
- [`repro/windows/current-machine/nvidia-smi.txt`](/D:/AI/Issac/repro/windows/current-machine/nvidia-smi.txt)

The `pip-freeze-full.txt` file is the full forensic snapshot of the current machine.
The `pip-postinstall-lock.txt` file is the practical post-install lock file used after `IsaacLab\isaaclab.bat -i rl_games`.

## Refreshing The Snapshot

If you update the environment on this machine and want to publish a new snapshot:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup\export_environment_snapshot.ps1
```

Then review the changed files under `repro/windows/current-machine/` before committing them.
