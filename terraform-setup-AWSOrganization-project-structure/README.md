
# Setup AWS Organization Terraform Configuration Script

## Overview

The `setup-aws-org-tf.sh` script automates the creation and configuration of Terraform directory structures and files for managing multiple AWS accounts within an AWS Organization. It ensures that each account has a standardized Terraform setup, including backend state storage in S3, provider configurations, and a modular directory structure. The script is idempotent, meaning it can be run multiple times without causing unintended side effects, ensuring that existing configurations are not overwritten.

## Features

- **Automated Directory Creation**: Creates an infrastructure directory structure, including global and account-specific directories.
- **S3 Backend Configuration**: Configures Terraform to use an S3 bucket for state storage, with unique paths for each account and a global configuration.
- **Providers Configuration**: Automatically generates `providers.tf` files for both global and account-specific directories.
- **Modular Directory Structure**: Ensures that each account directory contains a `modules` subdirectory, facilitating modular Terraform development.
- **Idempotency**: The script is designed to be run multiple times without overwriting existing files or directories, making it safe for repeated execution.
- **Error Handling**: Handles cases where AWS account information is incomplete or invalid, providing warnings and skipping problematic accounts.

## Assumptions

### User Permissions

The user running this script should have the following AWS permissions:

- **Organizations Permissions**: The ability to list AWS accounts (`organizations:ListAccounts`) within the AWS Organization.
- **S3 Permissions**: Permissions to create and manage S3 buckets and objects (`s3:CreateBucket`, `s3:PutObject`, etc.).
- **IAM Permissions**: The necessary permissions to configure AWS providers within Terraform.
- **File System Permissions**: The ability to create directories and files on the local machine where the script is being executed.

### Installed Software

The following software must be installed and accessible in the user's `PATH`:

- **AWS CLI**: The AWS Command Line Interface must be installed and configured. [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **jq**: A lightweight and flexible command-line JSON processor. [Installation Guide](https://stedolan.github.io/jq/download/)
- **Terraform**: Terraform must be installed for subsequent operations after the script runs. [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **Bash**: The script is designed to be run in a Bash shell, typically available on Unix-like systems (Linux, macOS).

## Usage

### Running the Script

1. **Download and Make the Script Executable**:
   ```bash
   wget <link-to-script> -O setup-aws-org-tf.sh
   chmod +x setup-aws-org-tf.sh
   ```

2. **Execute the Script**:
   ```bash
   ./setup-aws-org-tf.sh
   ```

3. **Provide the Required Inputs**:
   - **Infrastructure Directory**: When prompted, input the path where the Terraform infrastructure files should be located.
   - **S3 Bucket Name**: Provide the name of the S3 bucket to be used for storing Terraform state files.

### Script Workflow

1. **Infrastructure Directory Creation**:
   - The script begins by creating the specified `INFRASTRUCTURE_DIR`, along with subdirectories for `global` configurations and account-specific configurations (`accounts`).

2. **Global Directory Setup**:
   - A `modules` directory is created within the `GLOBAL_DIR`.
   - A `providers.tf` file is generated if it doesn't already exist.
   - A `backend.tf` file is created in the `GLOBAL_DIR`, configured to use the provided S3 bucket for storing the global Terraform state.

3. **Account Directory Setup**:
   - The script fetches a list of AWS accounts using the AWS CLI.
   - For each account, a directory is created under `ACCOUNTS_DIR` using the format `<aws_account_id>-<sanitized_account_name>`.
   - Within each account directory, a `modules` directory is created.
   - `backend.tf` and `providers.tf` files are generated for each account directory, configured to use the provided S3 bucket for storing the account-specific Terraform state.

4. **Idempotency Checks**:
   - The script checks for the existence of directories and files before attempting to create them, ensuring no existing configurations are overwritten.

## Customization

### Global `providers.tf`

The global `providers.tf` file, located in the `GLOBAL_DIR`, can be customized with additional provider configurations as needed. By default, the file includes a basic configuration for the AWS provider:

```hcl
provider "aws" {
  region = "us-east-1"
  # Additional provider configuration can be added here
}

provider "aws" {
  alias  = "secondary"
  region = "us-west-2"
  # Additional provider configuration for secondary region
}
```

### Account-Specific Configurations

Each account directory has its own `backend.tf` and `providers.tf` files. You can customize these files as needed for each specific account.

## Testing and Validation

### Test Cases

1. **Basic Execution**:
   - Ensure the script runs successfully and creates the required directory structure and files.

2. **Re-running the Script (Idempotency)**:
   - Verify that the script can be run multiple times without creating duplicate files or directories.

3. **Handling of Empty or Invalid AWS Account Information**:
   - Ensure the script handles cases where AWS account information is incomplete or invalid.

4. **Global Directory Setup**:
   - Confirm that the global directory setup is correct, including the creation of the `modules` directory and `providers.tf` file.

5. **Custom S3 Bucket Name Input**:
   - Verify that custom S3 bucket names provided by the user are correctly applied across all relevant files.

6. **Non-existent Infrastructure Directory**:
   - Test the script’s ability to handle non-existent infrastructure directories by creating them as needed.

### Edge Cases

- **Special Characters in Account Names**: Ensure the script handles special characters in account names appropriately by sanitizing them.
- **Large Number of Accounts**: Test the script’s performance and reliability when processing a large number of accounts.

# License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see [https://www.gnu.org/licenses/](https://www.gnu.org/licenses/).
