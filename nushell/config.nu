# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

# default editor
$env.config.buffer_editor = "nvim"

# Fix scroll issue with Wezterm
$env.config.shell_integration.osc133 = false

# C# Build Project/Solution
def bp [name] { fzf --filter ($name + ".csproj$") | sed 's|\\|/|g' | lines | first | xargs dotnet build -c Debug }
def bs [] { fzf --filter (".slnx$") | sed 's|\\|/|g' | lines | first | xargs dotnet build -c Debug -p:BuildUIWebSocket=false }
def bsf [] { fzf --filter (".slnx$") | sed 's|\\|/|g' | lines | first | xargs dotnet build -c Debug }

# Starship load
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

source ~/.zoxide.nu
