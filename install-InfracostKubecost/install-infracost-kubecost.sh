#!/bin/zsh

# Step 1: Update the System
echo "Updating the system..."
sudo zypper refresh && sudo zypper update -y

# Step 2: Install Homebrew if not already installed
if ! command -v brew &> /dev/null
then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to the PATH
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    source ~/.zshrc
else
    echo "Homebrew is already installed"
fi

# Step 3: Install Infracost
echo "Installing Infracost..."
brew install infracost

# Step 4: Install Helm (for Kubecost installation)
echo "Installing Helm..."
brew install helm

# Step 5: Add Kubecost Helm repository and install Kubecost
echo "Adding Kubecost repository and installing Kubecost..."
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
kubectl create namespace kubecost || echo "Namespace kubecost already exists."
helm install kubecost kubecost/cost-analyzer --namespace kubecost

# Step 6: Verify Installation
echo "Verifying Infracost installation..."
infracost --version

echo "Kubecost has been installed. You can access it by port-forwarding the service:"
echo "kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090"
echo "Then open http://localhost:9090 in your browser."

echo "Installation complete!"
