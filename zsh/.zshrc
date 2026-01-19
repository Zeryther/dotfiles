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
export ANDROID_HOME="$HOME/android_sdk"
export ADB_SERVER_SOCKET="tcp:localhost:5037"

# === Lazy-load NVM (huge startup time saver) ===
export NVM_DIR="$HOME/.nvm"
nvm() {
    unfunction nvm node npm npx
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

