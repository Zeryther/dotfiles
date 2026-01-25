set -e

# setup files on WSL (Ubuntu)

# install dependencies
echo ">> Installing dependencies..."
sudo apt-get install -y stow zsh build-essential procps curl file git zip # stow for linking, zsh for shell
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh # zoxide for better cd
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash # nvm for node development

if [[ ! -v ZSH ]]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" # oh my zsh for shell
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" # brew
echo ">> Done installing dependencies."

# setup links
echo ">> Linking zsh config..."
stow zsh
echo ">> zsh config linked."

echo ">> Linking bash config..."
stow bash
echo ">> bash config linked."

echo ">> Linking git config..."
stow git
echo ">> git config linked."

# set zsh as default shell
chsh -s $(which zsh)
