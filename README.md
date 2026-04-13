# Dotfiles

Personal configuration files for Neovim, WezTerm, and Nushell — synced across Windows, macOS, and Linux.

## What's Included

| Tool | Config Path in Repo |
|------|-------------------|
| **Neovim** (NvChad v2.5) | `nvim/` |
| **WezTerm** | `wezterm/.wezterm.lua` |
| **Nushell** | `nushell/config.nu` |

## Prerequisites

Install these before running the setup script:

- [Neovim](https://neovim.io/) (v0.10+)
- [WezTerm](https://wezfurlong.org/wezterm/)
- [Nushell](https://www.nushell.sh/)
- A [Nerd Font](https://www.nerdfonts.com/) (for icons in Neovim/WezTerm)
- [Git](https://git-scm.com/)

## Setup

### 1. Clone this repo

```sh
git clone https://github.com/PanamaP/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the setup script

**Windows** (PowerShell as Administrator):
```powershell
.\setup.ps1
```

**macOS / Linux**:
```sh
chmod +x setup.sh
./setup.sh
```

### 3. Open Neovim

On first launch, everything auto-installs:
- **lazy.nvim** bootstraps itself
- **NvChad** + all plugins download automatically
- **Mason** installs LSPs and debug adapters from the `ensure_installed` list

Just run `nvim` and wait for the initial setup to complete.

## Manual Symlink Commands

If you prefer not to use the setup scripts:

**Windows** (PowerShell as Administrator):
```powershell
# Neovim
New-Item -ItemType SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$PWD\nvim"

# WezTerm
New-Item -ItemType SymbolicLink -Path "$HOME\.wezterm.lua" -Target "$PWD\wezterm\.wezterm.lua"

# Nushell
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\nushell\config.nu" -Target "$PWD\nushell\config.nu"
```

**macOS / Linux**:
```sh
# Neovim
ln -s "$(pwd)/nvim" ~/.config/nvim

# WezTerm
ln -s "$(pwd)/wezterm/.wezterm.lua" ~/.wezterm.lua

# Nushell
ln -s "$(pwd)/nushell/config.nu" ~/.config/nushell/config.nu
```
