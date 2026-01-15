# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker docker-compose zsh-nvm ssh-agent zsh-auto-nvm-use)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source $HOME/.agent-bridge.sh

# bun completions
[ -s "/home/zeryther/.bun/_bun" ] && source "/home/zeryther/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# znap
# Download Znap, if it's not there yet.
[[ -r ~/Repos/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh  # Start Znap

znap prompt sindresorhus/pure
znap source marlonrichert/zsh-autocomplete

# zoxide
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init --cmd cd zsh)"

# vscode
#export PATH="/mnt/c/Users/zeryt/AppData/Local/Programs/Microsoft VS Code Insiders/bin:$PATH"

autoload -U compinit
compinit -i

#alias resetop="pkill socat && source ~/.agent-bridge.sh"
#pkill socat && source ~./.agent-bridge.sh

output=$(ssh-add -L 2>/dev/null)

# Check if ssh-add -L failed
if [ $? -ne 0 ]; then
    # Run your command here
    #echo "ssh-add -L failed"
    # Example command:
    pkill socat && source ~/.agent-bridge.sh
else
    #echo "ssh-add -L successful"
fi

export FLYCTL_INSTALL="/home/zeryther/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
. "/home/zeryther/.deno/env"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# pnpm
export PNPM_HOME="/home/zeryther/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# 1. Set ANDROID_HOME so Expo can find the SDK tools (like the emulator)
#export ANDROID_HOME="/mnt/c/Users/zeryt/AppData/Local/Android/Sdk"
export ANDROID_HOME=$HOME/Android/sdk

# 2. IMPORTANT: Do NOT add $ANDROID_HOME/platform-tools to the PATH.
#    This forces the system to use the Linux ADB located in /usr/bin,
#    which is already in the default PATH.

# 3. Keep this line to forward ADB commands from WSL to Windows
export ADB_SERVER_SOCKET=tcp:localhost:5037
. "/home/zeryther/.acme.sh/acme.sh.env"

export ANDROID_HOME=$HOME/android_sdk
export PATH=$PATH:$HOME/android_sdk/cmdline-tools/latest/bin
export PATH=$PATH:/mnt/c/Users/zeryt/AppData/Local/Android/Sdk/platform-tools

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
