# === Znap Plugin Manager ===
[[ -r ~/Repos/znap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh

# Prompt (replaces oh-my-zsh theme)
znap prompt sindresorhus/pure

# === Oh-My-Zsh ===
export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_UPDATE="true"  # Let znap handle updates if desired
plugins=(git docker docker-compose ssh-agent 1password)  # Removed nvm (loaded manually below)
source $ZSH/oh-my-zsh.sh

# === Autocomplete (after oh-my-zsh, handles compinit) ===
znap source marlonrichert/zsh-autocomplete

# === PATH Setup (consolidated) ===
typeset -U path  # Deduplicate PATH entries automatically
path=(
    $HOME/.local/bin
    $HOME/.bun/bin
    $HOME/.fly/bin
    $HOME/.local/share/pnpm
    $HOME/.opencode/bin
    $HOME/android_sdk/cmdline-tools/latest/bin
    /mnt/c/Users/zeryt/AppData/Local/Android/Sdk/platform-tools
    $path
)

# === Environment Variables ===
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"
export FLYCTL_INSTALL="$HOME/.fly"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export ANDROID_HOME="$HOME/android_sdk"
export ADB_SERVER_SOCKET="tcp:localhost:5037"
# The Android emulator runs on the Windows host behind NAT (10.0.2.x), so it
# can't reach WSL's LAN IP directly. Expo auto-detects the LAN IP and advertises
# it as the dev server address, which the emulator can't connect to. Setting this
# to "localhost" makes Expo advertise localhost instead. The emulator maps 10.0.2.2
# to the host's localhost, and with networkingMode=mirrored in .wslconfig, the
# host's localhost is also WSL's localhost — so the connection goes through.
export REACT_NATIVE_PACKAGER_HOSTNAME="localhost"

# === Lazy-load NVM (with immediate access to default node) ===
export NVM_DIR="$HOME/.nvm"

# Add default node to PATH immediately (fast, no nvm overhead)
if [[ -d "$NVM_DIR/versions/node" ]]; then
    DEFAULT_NODE=$(ls -v "$NVM_DIR/versions/node" | tail -1)
    if [[ -n "$DEFAULT_NODE" ]]; then
        path=("$NVM_DIR/versions/node/$DEFAULT_NODE/bin" $path)
    fi
fi

# Lazy-load nvm command itself (only needed for switching versions)
nvm() {
    unfunction nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}
node() { nvm --version >/dev/null && unfunction node && node "$@"; }
npm()  { nvm --version >/dev/null && unfunction npm  && npm "$@"; }
npx()  { nvm --version >/dev/null && unfunction npx  && npx "$@"; }

# === Bun completions ===
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# === Zoxide ===
eval "$(zoxide init --cmd cd zsh)"

# === Linuxbrew ===
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# === SSH Agent Bridge (WSL) ===
#if ! ssh-add -L &>/dev/null; then
#    pkill socat 2>/dev/null
#    source ~/.agent-bridge.sh
#fi

# === Aliases ===
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'

