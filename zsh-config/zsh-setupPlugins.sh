#!/bin/bash

# Update system and install Zsh if it's not already installed
sudo zypper update
sudo zypper install zsh git curl

# Oh My Zsh installation (if it's not installed already)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Zsh Custom Plugin Directory
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Install plugins using git clone

# 1. zsh-syntax-highlighting - Syntax highlighting for command clarity
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# 2. zsh-autosuggestions - Command history suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

# 3. zsh-completions - Extra completion definitions for DevOps tools (Kubernetes, Docker, AWS)
git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions

# 4. zsh-history-substring-search - History search using partial command matches
git clone https://github.com/zsh-users/zsh-history-substring-search.git $ZSH_CUSTOM/plugins/zsh-history-substring-search

# 5. Powerlevel10k - Fast and customizable theme with rich prompt support
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# 6. kubectl-zsh-plugin - Kubernetes command auto-completion support
git clone https://github.com/superbrothers/zsh-kubectl-prompt.git $ZSH_CUSTOM/plugins/kubectl-zsh-plugin

# 7. terraform-zsh-completion - Auto-completion for Terraform
git clone https://github.com/ljun20160606/terraform-zsh-plugin.git $ZSH_CUSTOM/plugins/terraform-zsh-completion

# 8. aws-vault-zsh-plugin - Manage AWS credentials securely
git clone https://github.com/blimmer/zsh-aws-vault.git $ZSH_CUSTOM/plugins/aws-vault

# 9. fzf-tab - Enhance tab completion with fuzzy searching
git clone https://github.com/Aloxaf/fzf-tab.git $ZSH_CUSTOM/plugins/fzf-tab

# Configure .zshrc
cat <<EOF >> $HOME/.zshrc

# Enable plugins
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  kubectl-zsh-plugin
  terraform-zsh-completion
  aws-vault
  fzf-tab
)

# Enable Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan'

# Enable syntax highlighting
source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable history substring search
source \$ZSH_CUSTOM/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Load zsh completions
autoload -U compinit && compinit

# Enable fuzzy tab completion
source \$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh

EOF

# Change default shell to Zsh
chsh -s $(which zsh)

# Done
echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc'."
