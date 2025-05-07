#!/bin/bash

# Habilitar errores y salidas informativas
set -e
echo "Initializing setup..."

# Determinar el directorio del script (y por extensión, la raíz del repo de dotfiles)
# Esto asume que el script se ejecuta desde dentro del repositorio clonado
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
DOTFILES_SOURCE_DIR="$SCRIPT_DIR/dotfiles"

echo "Script directory: $SCRIPT_DIR"
echo "Dotfiles source directory: $DOTFILES_SOURCE_DIR"

# Comprobar si el directorio de dotfiles existe
if [ ! -d "$DOTFILES_SOURCE_DIR" ]; then
  echo "Error: Directory $DOTFILES_SOURCE_DIR not found."
  echo "Please ensure you are running this script from the root of the cloned Configurations repository."
  exit 1
fi

# Actualizar lista de paquetes
echo "Updating package list..."
sudo pacman -Syu

# Instalar paquetes necesarios (asegurarse de que git está instalado si no lo estaba)
echo "Installing required packages..."
sudo pacman -S zsh curl wget git

# Crear enlaces simbólicos para los dotfiles
echo "Creating symbolic links for dotfiles..."

# .gitconfig
echo "Linking .gitconfig..."
ln -sf "$DOTFILES_SOURCE_DIR/.gitconfig" ~/

# git config (allowed_signers)
echo "Linking git allowed_signers..."
mkdir -p ~/.config/git
ln -sf "$DOTFILES_SOURCE_DIR/allowed_signers" ~/.config/git/

# .p10k.zsh
echo "Linking .p10k.zsh..."
ln -sf "$DOTFILES_SOURCE_DIR/.p10k.zsh" ~/

# .p10k.zsh
echo "Linking .zshrc..."
ln -sf "$DOTFILES_SOURCE_DIR/.zshrc" ~/

# Instalar fzf (fuzzy finder)
echo "Installing fzf from GitHub..."
if [ -d "$HOME/.fzf" ]; then
  echo "fzf already installed in ~/.fzf. Skipping clone."
else
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
# Ejecutar el script de instalación de forma no interactiva
~/.fzf/install --all

# Instalar zoxide (smart cd command)
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Cambiar la shell por defecto a zsh para el usuario actual
# Necesita ejecutarse después de que zsh esté instalado
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  # Nota: chsh puede pedir la contraseña del usuario
  sudo chsh -s "$(which zsh)" "$USER"
  echo "Default shell changed to zsh. Please log out and log back in for the change to take effect."
else
  echo "Default shell is already zsh."
fi

# Cambiar el URL del repositorio remoto
echo "Setting remote origin URL..."
git remote set-url origin git@github.com:ruescalante/.nykoconfig.git

echo "Setup complete!"
