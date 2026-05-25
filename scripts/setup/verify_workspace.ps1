$ErrorActionPreference = "Stop"

$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$pythonExe = Join-Path $workspace "env_isaaclab\Scripts\python.exe"
$assetUsd = Join-Path $workspace ".isaaclab_cache\ant_3joint\ant_3joint.usda"

if (!(Test-Path -LiteralPath $pythonExe)) {
    throw "Python environment not found: $pythonExe"
}

@'
import json
import pathlib
import sys

import torch

summary = {
    "python_executable": sys.executable,
    "python_version": sys.version.split()[0],
    "torch_version": torch.__version__,
    "torch_cuda": torch.version.cuda,
    "cuda_available": torch.cuda.is_available(),
    "gpu_count": torch.cuda.device_count(),
    "gpu_names": [torch.cuda.get_device_name(i) for i in range(torch.cuda.device_count())],
}
print(json.dumps(summary, indent=2))
'@ | & $pythonExe -

if (Test-Path -LiteralPath $assetUsd) {
    Write-Host "Asset USD present: $assetUsd"
} else {
    Write-Host "Asset USD missing: $assetUsd"
    Write-Host "Run .\\scripts\\setup\\init_workspace.ps1 -BuildProjectAssets"
}
