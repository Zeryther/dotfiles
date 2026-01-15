set -e

# setup files on WSL (Ubuntu)

# install dependencies
echo ">> Installing dependencies..."
sudo apt-get install -y stow zsh # stow for linking, zsh for shell
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh # zoxide for better cd
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash # nvm for node development
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

