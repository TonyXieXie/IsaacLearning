param(
    [int]$MaxIterations = 30518,
    [string]$ExperimentName = "",
    [switch]$NoHeadless
)

$ErrorActionPreference = "Stop"

$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$isaacLabRoot = Join-Path $workspace "IsaacLab"
$pythonExe = Join-Path $workspace "env_isaaclab\Scripts\python.exe"
$trainScript = Join-Path $isaacLabRoot "scripts\reinforcement_learning\rl_games\train.py"

if ([string]::IsNullOrWhiteSpace($ExperimentName)) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $ExperimentName = "${timestamp}_cmdramp_air_gait_force_2000m"
}

if (!(Test-Path -LiteralPath $pythonExe)) {
    throw "Python executable not found: $pythonExe"
}

if (!(Test-Path -LiteralPath $trainScript)) {
    throw "Training script not found: $trainScript"
}

$env:OMNI_KIT_ACCEPT_EULA = "YES"

$arguments = @(
    $trainScript,
    "--task", "Isaac-Velocity-Flat-Ant-3Joint-v0",
    "--max_iterations", $MaxIterations.ToString()
)

if (-not $NoHeadless) {
    $arguments += "--headless"
}

$arguments += "+agent.params.config.full_experiment_name=$ExperimentName"

Write-Host "Launching training:"
Write-Host "  Task: Isaac-Velocity-Flat-Ant-3Joint-v0"
Write-Host "  Max iterations: $MaxIterations"
Write-Host "  Experiment name: $ExperimentName"

Set-Location $isaacLabRoot
& $pythonExe @arguments
exit $LASTEXITCODE
