# Terraform Aliases

# Initialization
alias tfi='terraform init'

# Validation
alias tfv='terraform validate'

# Planning
alias tfp='terraform plan'

# Applying
alias tfa='terraform apply'
alias tfaa='terraform apply --auto-approve'

# Destroying
alias tfd='terraform destroy'
alias tfda='terraform destroy --auto-approve'

# Refreshing
alias tfr='terraform refresh'

# Output
alias tfo='terraform output'

# Formatting
alias tff='terraform fmt'

# Workspace
alias tfws='terraform workspace'
alias tfwsn='terraform workspace new'
alias tfwss='terraform workspace select'
alias tfwsl='terraform workspace list'
alias tfwsshow='terraform workspace show'

# Importing
alias tfim='terraform import'

# Tainting
alias tft='terraform taint'
alias tfut='terraform untaint'

# Graph
alias tfg='terraform graph'

# State Management
alias tfsh='terraform show'
alias tfs='terraform state'
alias tfsl='terraform state list'
alias tfsm='terraform state mv'
alias tfsrm='terraform state rm'
alias tfss='terraform state show'

### Terraform Base File Creation
alias ctfb='touch {main.tf,outputs.tf,terraform.tfvars,variables.tf}'

# Saving this script to terraform_aliases.sh and sourcing it in your shell's
# startup script (.bashrc, .bash_profile, .zshrc, etc.) allows you to use these
# shorthand commands in your terminal.

