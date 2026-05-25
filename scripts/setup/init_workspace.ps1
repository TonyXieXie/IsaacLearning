param(
    [switch]$InstallRlGames,
    [switch]$InstallPinnedPackages,
    [switch]$BuildProjectAssets
)

$ErrorActionPreference = "Stop"

$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$isaacLabRoot = Join-Path $workspace "IsaacLab"
$isaacLabBat = Join-Path $isaacLabRoot "isaaclab.bat"
$pythonExe = Join-Path $workspace "env_isaaclab\Scripts\python.exe"
$assetUsd = Join-Path $workspace ".isaaclab_cache\ant_3joint\ant_3joint.usda"
$pinnedRequirements = Join-Path $workspace "repro\windows\current-machine\pip-postinstall-lock.txt"

Write-Host "Workspace root: $workspace"

git -C $workspace submodule sync --recursive
git -C $workspace submodule update --init --recursive

if ($InstallRlGames) {
    if (!(Test-Path -LiteralPath $isaacLabBat)) {
        throw "IsaacLab launcher not found: $isaacLabBat"
    }
    Write-Host "Installing IsaacLab rl_games dependencies..."
    Push-Location $isaacLabRoot
    try {
        & $isaacLabBat -i rl_games
    } finally {
        Pop-Location
    }
}

if (Test-Path -LiteralPath $pythonExe) {
    Write-Host "Python environment detected: $pythonExe"
} else {
    Write-Host "Python environment not found at: $pythonExe"
    Write-Host "Create it from IsaacLab with:"
    Write-Host "  cd $isaacLabRoot"
    Write-Host "  .\\isaaclab.bat -i rl_games"
}

if ($InstallPinnedPackages) {
    if (!(Test-Path -LiteralPath $pythonExe)) {
        throw "Cannot install pinned packages because Python environment was not found: $pythonExe"
    }
    if (!(Test-Path -LiteralPath $pinnedRequirements)) {
        throw "Pinned requirements file not found: $pinnedRequirements"
    }
    Write-Host "Installing pinned packages from current working snapshot..."
    & $pythonExe -m pip install -r $pinnedRequirements
}

if ($BuildProjectAssets -or ((Test-Path -LiteralPath $pythonExe) -and !(Test-Path -LiteralPath $assetUsd))) {
    if (!(Test-Path -LiteralPath $isaacLabBat)) {
        throw "IsaacLab launcher not found: $isaacLabBat"
    }
    Write-Host "Building project assets..."
    Push-Location $isaacLabRoot
    try {
        & $isaacLabBat -p scripts/tools/build_ant_3joint_asset.py --headless
    } finally {
        Pop-Location
    }
}

Write-Host "Workspace initialization complete."
