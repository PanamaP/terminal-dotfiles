# setup.ps1 — Symlink dotfiles to the correct locations on Windows
# Run as Administrator (required for symlinks)

$ErrorActionPreference = "Stop"
$DotfilesDir = $PSScriptRoot

function New-Symlink {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (Test-Path $Destination) {
        $item = Get-Item $Destination -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Write-Host "  Removing existing symlink: $Destination"
            Remove-Item $Destination -Force
        } else {
            Write-Host "  Backing up existing: $Destination -> ${Destination}.bak"
            Move-Item $Destination "${Destination}.bak" -Force
        }
    }

    $parent = Split-Path $Destination -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $isDir = Test-Path $Source -PathType Container
    if ($isDir) {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    }
    Write-Host "  Linked: $Destination -> $Source"
}

# Check for admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges for creating symlinks." -ForegroundColor Red
    Write-Host "Please re-run PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

Write-Host "Setting up dotfiles from: $DotfilesDir"
Write-Host ""

Write-Host "[Neovim]"
New-Symlink -Source "$DotfilesDir\nvim" -Destination "$env:LOCALAPPDATA\nvim"

Write-Host "[WezTerm]"
# Clean up old single-file symlink if it exists
if (Test-Path "$HOME\.wezterm.lua") {
    $item = Get-Item "$HOME\.wezterm.lua" -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "  Removing old symlink: $HOME\.wezterm.lua"
        Remove-Item "$HOME\.wezterm.lua" -Force
    } else {
        Write-Host "  Backing up old config: $HOME\.wezterm.lua -> $HOME\.wezterm.lua.bak"
        Move-Item "$HOME\.wezterm.lua" "$HOME\.wezterm.lua.bak" -Force
    }
}
New-Symlink -Source "$DotfilesDir\wezterm" -Destination "$HOME\.config\wezterm"

Write-Host "[Nushell]"
New-Symlink -Source "$DotfilesDir\nushell\config.nu" -Destination "$env:APPDATA\nushell\config.nu"
New-Symlink -Source "$DotfilesDir\nushell\env.nu" -Destination "$env:APPDATA\nushell\env.nu"

Write-Host ""
Write-Host "Done! Open nvim to trigger first-time plugin installation." -ForegroundColor Green
