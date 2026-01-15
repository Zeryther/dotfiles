set -e

# setup files on WSL (Ubuntu)

# install stow
echo ">> Installing stow..."
sudo apt-get install -y stow
echo ">> Done installing stow."

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

