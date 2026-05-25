# Issac Workspace

This repository is the parent workspace for local Isaac Lab experiments, project-specific assets, helper scripts, and reports.

## Layout

- `IsaacLab/`: child repository for IsaacLab code and task-level changes
- `assets/mjcf/ant_3joint/robot.xml`: MJCF source for the custom ant variant
- `scripts/windows/start_ant_gui.ps1`, `scripts/windows/start_ant_gui.cmd`: local playback launchers
- `reports/ant_3joint/ant_3joint_limb_ranges.html`: local inspection report
- `env_isaaclab/`: machine-local Python environment, not tracked
- `.isaaclab_cache/`: generated USD/cache assets, not tracked
- `logs/`, `outputs/`: runtime outputs, not tracked

## Git Strategy

1. Track this outer workspace in its own Git repository.
2. Keep project-specific scripts, assets, and docs here.
3. Track `IsaacLab/` as a child repository reference from the outer repo.

## Remote Layout

- Outer repo: `https://github.com/TonyXieXie/IsaacLearning.git`
- Child repo: `https://github.com/TonyXieXie/IsaacLab.git`
- Child upstream: `https://github.com/isaac-sim/IsaacLab.git`

Create `TonyXieXie/IsaacLab` on GitHub before the first push from this machine.

## Commit Order

1. Commit your code changes inside `IsaacLab/` first.
2. Push that IsaacLab commit to a remote that the outer repo can reference.
3. Commit the outer repo after the `IsaacLab/` child reference has advanced to the desired commit.

## Clone On Another Computer

1. `git clone --recurse-submodules https://github.com/TonyXieXie/IsaacLearning.git`
2. `cd IsaacLearning`
3. `powershell -ExecutionPolicy Bypass -File .\scripts\setup\init_workspace.ps1`
4. If `env_isaaclab\Scripts\python.exe` does not exist yet, install the IsaacLab environment from `IsaacLab\isaaclab.bat`.
5. Launch training with `.\scripts\windows\train_ant_3joint_velocity_flat.cmd`

For a closer-to-identical Windows setup, use [docs/windows-training-setup.md](/D:/AI/Issac/docs/windows-training-setup.md).

## Local Runtime State

Training outputs, checkpoints, caches, and the Python environment remain intentionally local.
Only source assets, scripts, and repository metadata should be synchronized from this outer repo.
