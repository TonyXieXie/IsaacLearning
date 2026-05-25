param(
    [string]$Checkpoint = "",
    [int]$NumEnvs = 1
)

$ErrorActionPreference = "Stop"

$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$isaacLabRoot = Join-Path $workspace "IsaacLab"
$pythonExe = Join-Path $workspace "env_isaaclab\Scripts\python.exe"
$playScript = Join-Path $isaacLabRoot "scripts\reinforcement_learning\rl_games\play.py"
$antLogsRoot = Join-Path $isaacLabRoot "logs\rl_games\ant"
$h5pyDllDir = Join-Path $workspace "env_isaaclab\Lib\site-packages\h5py"

function Resolve-Checkpoint([string]$checkpointPath) {
    if (![string]::IsNullOrWhiteSpace($checkpointPath)) {
        return $checkpointPath
    }

    $latestRun = Get-ChildItem -LiteralPath $antLogsRoot -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $latestRun) {
        throw "No Ant training run found under: $antLogsRoot"
    }

    $defaultCheckpoint = Join-Path $latestRun.FullName "nn\ant.pth"
    if (Test-Path -LiteralPath $defaultCheckpoint) {
        return $defaultCheckpoint
    }

    $latestCheckpoint = Get-ChildItem -LiteralPath (Join-Path $latestRun.FullName "nn") -Filter *.pth -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $latestCheckpoint) {
        throw "No checkpoint found under: $($latestRun.FullName)\nn"
    }

    return $latestCheckpoint.FullName
}

if (!(Test-Path -LiteralPath $pythonExe)) {
    throw "Python executable not found: $pythonExe"
}

if (!(Test-Path -LiteralPath $playScript)) {
    throw "RL-Games play script not found: $playScript"
}

if (!(Test-Path -LiteralPath $h5pyDllDir)) {
    throw "h5py DLL directory not found: $h5pyDllDir"
}

$Checkpoint = Resolve-Checkpoint -checkpointPath $Checkpoint

if (!(Test-Path -LiteralPath $Checkpoint)) {
    throw "Checkpoint not found: $Checkpoint"
}

$env:OMNI_KIT_ACCEPT_EULA = "YES"
$env:PATH = "$h5pyDllDir;$env:PATH"

$arguments = @(
    $playScript,
    "--task", "Isaac-Ant-v0",
    "--num_envs", $NumEnvs.ToString(),
    "--checkpoint", $Checkpoint,
    "--real-time",
    "--disable_fabric"
)

Write-Host "Launching Isaac Sim GUI with checkpoint:"
Write-Host $Checkpoint

Set-Location $isaacLabRoot
& $pythonExe @arguments
exit $LASTEXITCODE
