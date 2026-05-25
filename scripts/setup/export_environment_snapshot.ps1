$ErrorActionPreference = "Stop"

$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pythonExe = Join-Path $workspace "env_isaaclab\Scripts\python.exe"
$snapshotDir = Join-Path $workspace "repro\windows\current-machine"

if (!(Test-Path -LiteralPath $pythonExe)) {
    throw "Python environment not found: $pythonExe"
}

New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

& $pythonExe --version | Set-Content -Path (Join-Path $snapshotDir "python-version.txt")
& $pythonExe -m pip freeze | Set-Content -Path (Join-Path $snapshotDir "pip-freeze-full.txt")

@'
import json
import os
import pathlib
import platform
import subprocess
import sys

import torch

workspace = pathlib.Path(sys.argv[1])
inner = workspace / "IsaacLab"

def git_output(args, cwd):
    return subprocess.check_output(args, cwd=cwd, text=True).strip()

payload = {
    "workspace": str(workspace),
    "platform": platform.platform(),
    "python_version": sys.version,
    "python_executable": sys.executable,
    "torch_version": torch.__version__,
    "torch_cuda": torch.version.cuda,
    "cuda_available": torch.cuda.is_available(),
    "gpu_count": torch.cuda.device_count(),
    "gpu_names": [torch.cuda.get_device_name(i) for i in range(torch.cuda.device_count())],
    "outer_repo_commit": git_output(["git", "rev-parse", "HEAD"], workspace),
    "inner_repo_commit": git_output(["git", "rev-parse", "HEAD"], inner),
}
print(json.dumps(payload, indent=2, ensure_ascii=False))
'@ | & $pythonExe - $workspace | Set-Content -Path (Join-Path $snapshotDir "metadata.json")

@'
from pathlib import Path
import subprocess
import sys

workspace = Path(sys.argv[1])
lines = subprocess.check_output([sys.executable, "-m", "pip", "freeze"], text=True).splitlines()
portable = []
for line in lines:
    if line.startswith("-e git+ssh://git@github.com/TonyXieXie/IsaacLab.git"):
        continue
    portable.append(line)
print("\n".join(portable))
'@ | & $pythonExe - $workspace | Set-Content -Path (Join-Path $snapshotDir "pip-postinstall-lock.txt")

try {
    nvidia-smi | Set-Content -Path (Join-Path $snapshotDir "nvidia-smi.txt")
} catch {
    $_ | Out-String | Set-Content -Path (Join-Path $snapshotDir "nvidia-smi.txt")
}

Write-Host "Environment snapshot written to: $snapshotDir"
