#!/bin/zsh

# Step 1: Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Installing it now..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed."
fi

# Step 2: Define plugin directory for custom plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Step 3: Install kubectl-zsh-plugin
if [ ! -d "${ZSH_CUSTOM}/plugins/kubectl-zsh-plugin" ]; then
    echo "Installing kubectl-zsh-plugin..."
    git clone https://github.com/superbrothers/zsh-kubectl-prompt "${ZSH_CUSTOM}/plugins/kubectl-zsh-plugin"
else
    echo "kubectl-zsh-plugin is already installed."
fi

# Step 4: Install Terraform Zsh Completion from HashiCorp
if [ ! -d "${ZSH_CUSTOM}/plugins/terraform" ]; then
    echo "Installing Terraform zsh completion..."
    mkdir -p "${ZSH_CUSTOM}/plugins/terraform"
    curl -o "${ZSH_CUSTOM}/plugins/terraform/_terraform" https://raw.githubusercontent.com/hashicorp/terraform/main/contrib/zsh/_terraform
else
    echo "Terraform zsh completion is already installed."
fi

# Step 5: Install aws-vault if not already installed
if ! command -v aws-vault &> /dev/null; then
    echo "Installing aws-vault..."
    brew install aws-vault
else
    echo "aws-vault is already installed."
fi

# Step 6: Add plugins to .zshrc
echo "Adding plugins to .zshrc if not already present..."
if ! grep -q "kubectl-zsh-plugin" ~/.zshrc; then
    sed -i 's/^plugins=(/&kubectl-zsh-plugin /' ~/.zshrc
fi
if ! grep -q "terraform" ~/.zshrc; then
    sed -i 's/^plugins=(/&terraform /' ~/.zshrc
fi
if ! grep -q "aws-vault" ~/.zshrc; then
    sed -i 's/^plugins=(/&aws-vault /' ~/.zshrc
fi

# Step 7: Source the updated .zshrc
echo "Sourcing .zshrc to apply changes..."
source ~/.zshrc

echo "Installation and configuration of plugins complete!"
