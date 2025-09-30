#!/bin/bash

# Prompt the user to input the infrastructure directory
read -p "Enter the path to the infrastructure directory: " INFRASTRUCTURE_DIR

# Define paths to the global and accounts directories
GLOBAL_DIR="$INFRASTRUCTURE_DIR/global"
ACCOUNTS_DIR="$INFRASTRUCTURE_DIR/accounts"

# Ensure the infrastructure directory exists
if [ ! -d "$INFRASTRUCTURE_DIR" ]; then
    echo "The infrastructure directory $INFRASTRUCTURE_DIR does not exist. Creating it..."
    mkdir -p "$INFRASTRUCTURE_DIR"
    mkdir -p "$ACCOUNTS_DIR"
    mkdir -p "$GLOBAL_DIR"
    echo "Created infrastructure, global, and accounts directories."
else
    echo "Infrastructure directory $INFRASTRUCTURE_DIR already exists."
fi

# Ensure the global and accounts directories exist
if [ ! -d "$GLOBAL_DIR" ]; then
    echo "Global directory does not exist. Creating it..."
    mkdir -p "$GLOBAL_DIR"
else
    echo "Global directory $GLOBAL_DIR already exists."
fi

if [ ! -d "$ACCOUNTS_DIR" ]; then
    echo "Accounts directory does not exist. Creating it..."
    mkdir -p "$ACCOUNTS_DIR"
else
    echo "Accounts directory $ACCOUNTS_DIR already exists."
fi

# Function to sanitize account names by replacing spaces with hyphens
sanitize_account_name() {
    echo "$1" | tr ' ' '-' | tr '[:upper:]' '[:lower:]'
}

# Function to create account directory based on AWS account ID and sanitized account name
create_account_directory() {
    local aws_account_id=$1
    local account_name=$2
    local sanitized_name=$(sanitize_account_name "$account_name")
    local account_dir="${ACCOUNTS_DIR}/${aws_account_id}-${sanitized_name}"
    
    if [ ! -d "$account_dir" ]; then
        mkdir -p "$account_dir"
        echo "Created directory: $account_dir"
    else
        echo "Directory already exists: $account_dir"
    fi

    # Ensure the modules directory exists in the account directory
    if [ ! -d "$account_dir/modules" ]; then
        mkdir -p "$account_dir/modules"
        echo "Created modules directory in $account_dir."
    else
        echo "Modules directory already exists in $account_dir."
    fi

    echo "$account_dir"
}

# Fetch the list of AWS accounts from AWS Organizations
fetch_aws_accounts() {
    echo "Fetching AWS accounts from AWS Organizations..."
    aws organizations list-accounts --output json | jq -c '.Accounts[] | {Id, Name}'
}

# Loop to create account directories and set up Terraform configuration based on AWS Organizations accounts
populate_accounts_directories() {
    local accounts_json=$(fetch_aws_accounts)
    
    echo "$accounts_json" | while read -r account; do
        aws_account_id=$(echo "$account" | jq -r '.Id')
        account_name=$(echo "$account" | jq -r '.Name')

        # Create the account directory
        account_dir=$(create_account_directory "$aws_account_id" "$account_name")
        
        echo "Processing $aws_account_id-$account_name..."
    done
}

# Function to set up backend.tf and providers.tf files after S3 bucket is provided by the user
setup_terraform_files() {
    read -p "Enter the S3 bucket name for Terraform state storage: " S3_BUCKET
    REGION="us-east-1"

    # Setup backend.tf in the global directory with a global name
    if [ ! -f "$GLOBAL_DIR/backend.tf" ]; then
        echo "Creating backend.tf in the global directory..."
        cat > "$GLOBAL_DIR/backend.tf" <<EOF
terraform {
  backend "s3" {
    bucket  = "${S3_BUCKET}"
    key     = "state/global/terraform.tfstate"
    region  = "${REGION}"
    encrypt = true
  }
}
EOF
    else
        echo "Warning: backend.tf already exists in the global directory. Skipping creation."
    fi

    for account_dir in "$ACCOUNTS_DIR"/*; do
        if [ -d "$account_dir" ]; then
            sanitized_name=$(basename "$account_dir" | cut -d'-' -f2-)

            # Create backend.tf
            if [ ! -f "$account_dir/backend.tf" ]; then
                echo "Creating backend.tf in $account_dir..."
                cat > "$account_dir/backend.tf" <<EOF
terraform {
  backend "s3" {
    bucket  = "${S3_BUCKET}"
    key     = "state/${sanitized_name}/terraform.tfstate"
    region  = "${REGION}"
    encrypt = true
  }
}
EOF
            else
                echo "Warning: backend.tf already exists in $account_dir. Skipping creation."
            fi

            # Create providers.tf
            if [ ! -f "$account_dir/providers.tf" ]; then
                echo "Creating providers.tf in $account_dir..."
                cat > "$account_dir/providers.tf" <<EOF
provider "aws" {
  region = "${REGION}"
  # Additional provider configuration can be added here
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
  # Additional provider configuration for secondary region
}
EOF
            else
                echo "Warning: providers.tf already exists in $account_dir. Skipping creation."
            fi

            echo "Setup completed for $account_dir."
        else
            echo "Warning: Account directory $account_dir does not exist. Skipping."
        fi
    done
}

# Main execution
populate_accounts_directories
setup_terraform_files

echo "All AWS account directories have been processed."
