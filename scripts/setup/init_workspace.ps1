param(
    [switch]$InstallRlGames
)

$ErrorActionPreference = "Stop"

$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$isaacLabRoot = Join-Path $workspace "IsaacLab"
$isaacLabBat = Join-Path $isaacLabRoot "isaaclab.bat"
$pythonExe = Join-Path $workspace "env_isaaclab\Scripts\python.exe"

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

Write-Host "Workspace initialization complete."
