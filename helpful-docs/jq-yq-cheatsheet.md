# 🧘 The Enlightened Engineer's jq & yq Scripture

> *"In the beginning was the JSON, and the JSON was with jq, and the JSON was queryable."*  
> — **The Monk of Data Parsing**, *Book of Queries, Chapter 1:1*

This scripture covers jq (JSON processor) and yq (YAML processor) - essential tools for data manipulation.

---

## 📿 jq - JSON Processor

### Basic Usage
```bash
# Pretty print JSON
echo '{"name":"John","age":30}' | jq '.'

# Read from file
jq '.' file.json

# Compact output
jq -c '.' file.json

# Raw output (no quotes)
jq -r '.name' file.json
```

### Selecting Fields
```bash
# Select single field
jq '.name' file.json

# Select nested field
jq '.user.name' file.json

# Select multiple fields
jq '.name, .age' file.json

# Select array element
jq '.[0]' file.json
jq '.[0].name' file.json
```

### Array Operations
```bash
# Get all elements
jq '.[]' file.json

# Get specific element
jq '.[2]' file.json

# Get range
jq '.[0:3]' file.json

# Get length
jq '.[] | length' file.json

# Map over array
jq '.[] | .name' file.json

# Filter array
jq '.[] | select(.age > 25)' file.json
```

### Filtering
```bash
# Select where condition
jq '.[] | select(.age > 30)' file.json

# Multiple conditions
jq '.[] | select(.age > 30 and .name == "John")' file.json

# Contains
jq '.[] | select(.name | contains("John"))' file.json

# Starts with
jq '.[] | select(.name | startswith("J"))' file.json

# Ends with
jq '.[] | select(.name | endswith("n"))' file.json
```

### Transformations
```bash
# Create new object
jq '{name: .name, age: .age}' file.json

# Add field
jq '. + {new_field: "value"}' file.json

# Remove field
jq 'del(.field)' file.json

# Rename field
jq '{new_name: .old_name}' file.json

# Map array
jq '[.[] | {name: .name}]' file.json
```

### Functions
```bash
# Keys
jq 'keys' file.json

# Values
jq 'values' file.json

# Type
jq 'type' file.json

# Length
jq 'length' file.json

# Sort
jq 'sort' file.json
jq 'sort_by(.age)' file.json

# Reverse
jq 'reverse' file.json

# Unique
jq 'unique' file.json

# Group by
jq 'group_by(.category)' file.json
```

### Aggregation
```bash
# Min/Max
jq '[.[] | .age] | min' file.json
jq '[.[] | .age] | max' file.json

# Sum
jq '[.[] | .age] | add' file.json

# Average
jq '[.[] | .age] | add / length' file.json

# Count
jq '[.[] | select(.age > 30)] | length' file.json
```

### String Operations
```bash
# Concatenate
jq '.first_name + " " + .last_name' file.json

# Split
jq '.name | split(" ")' file.json

# Join
jq '.tags | join(", ")' file.json

# To upper/lower
jq '.name | ascii_upcase' file.json
jq '.name | ascii_downcase' file.json

# Substring
jq '.name[0:3]' file.json
```

### Conditionals
```bash
# If-then-else
jq 'if .age > 18 then "adult" else "minor" end' file.json

# Multiple conditions
jq 'if .age < 13 then "child" elif .age < 18 then "teen" else "adult" end' file.json

# Ternary
jq '.age > 18 | if . then "adult" else "minor" end' file.json
```

### Common Patterns
```bash
# Extract specific fields from array
jq '[.[] | {name: .name, email: .email}]' users.json

# Filter and transform
jq '[.[] | select(.active == true) | {id: .id, name: .name}]' users.json

# Flatten nested arrays
jq '[.[] | .items[]] | unique' file.json

# Count by field
jq 'group_by(.status) | map({status: .[0].status, count: length})' file.json

# Merge objects
jq '. + {updated_at: now}' file.json
```

---

## 📘 yq - YAML Processor

### Basic Usage
```bash
# Pretty print YAML
yq '.' file.yaml

# Convert YAML to JSON
yq -o json '.' file.yaml

# Convert JSON to YAML
yq -P '.' file.json

# Read from file
yq '.name' file.yaml
```

### Selecting Fields
```bash
# Select single field
yq '.name' file.yaml

# Select nested field
yq '.spec.containers[0].name' deployment.yaml

# Select multiple fields
yq '.name, .age' file.yaml

# Select array element
yq '.[0]' file.yaml
```

### Array Operations
```bash
# Get all elements
yq '.[]' file.yaml

# Get specific element
yq '.[2]' file.yaml

# Get length
yq '. | length' file.yaml

# Map over array
yq '.[] | .name' file.yaml

# Filter array
yq '.[] | select(.age > 25)' file.yaml
```

### Kubernetes Examples
```bash
# Get container image
yq '.spec.containers[0].image' deployment.yaml

# Get all container names
yq '.spec.containers[].name' deployment.yaml

# Get service ports
yq '.spec.ports[].port' service.yaml

# Get all labels
yq '.metadata.labels' deployment.yaml

# Get specific label
yq '.metadata.labels.app' deployment.yaml
```

### Modifications
```bash
# Update field
yq '.name = "new-name"' file.yaml

# Update nested field
yq '.spec.replicas = 3' deployment.yaml

# Add field
yq '.metadata.annotations.note = "updated"' file.yaml

# Delete field
yq 'del(.spec.strategy)' deployment.yaml

# Update in place
yq -i '.spec.replicas = 5' deployment.yaml
```

### Merging
```bash
# Merge two YAML files
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' file1.yaml file2.yaml

# Merge with precedence
yq eval-all '. as $item ireduce ({}; . * $item)' file1.yaml file2.yaml
```

### Common Patterns
```bash
# Get all Kubernetes resources of a type
yq 'select(.kind == "Deployment")' *.yaml

# Update image tag
yq '.spec.containers[0].image = "nginx:1.21"' deployment.yaml

# Add environment variable
yq '.spec.containers[0].env += [{"name": "NEW_VAR", "value": "value"}]' deployment.yaml

# Scale deployment
yq '.spec.replicas = 3' deployment.yaml

# Change service type
yq '.spec.type = "LoadBalancer"' service.yaml
```

---

## 🔮 Real-World Examples

### jq: Parse API Response
```bash
# Get user names from API
curl -s https://api.github.com/users | jq '.[].login'

# Get specific fields
curl -s https://api.github.com/repos/kubernetes/kubernetes | jq '{name: .name, stars: .stargazers_count, forks: .forks_count}'

# Filter and sort
curl -s https://api.github.com/users | jq '[.[] | {login: .login, id: .id}] | sort_by(.id)'
```

### yq: Kubernetes Manifests
```bash
# Get all container images
yq '.spec.containers[].image' deployment.yaml

# Update all replicas to 3
yq '.spec.replicas = 3' deployment.yaml

# Add label to all resources
yq '.metadata.labels.environment = "production"' *.yaml

# Get all services with type LoadBalancer
yq 'select(.kind == "Service" and .spec.type == "LoadBalancer")' *.yaml
```

### Combined: CI/CD Pipeline
```bash
# Extract version from package.json
VERSION=$(jq -r '.version' package.json)

# Update Kubernetes deployment with new version
yq -i ".spec.containers[0].image = \"myapp:${VERSION}\"" k8s/deployment.yaml

# Validate Kubernetes YAML
yq '.' k8s/*.yaml > /dev/null && echo "Valid YAML"
```

---

## 🙏 Quick Reference

### jq
| Command | Description |
|---------|-------------|
| `jq '.'` | Pretty print |
| `jq '.field'` | Select field |
| `jq '.[]'` | Array elements |
| `jq 'select(.age > 30)'` | Filter |
| `jq 'map(.name)'` | Map array |
| `jq 'keys'` | Get keys |
| `jq 'length'` | Get length |

### yq
| Command | Description |
|---------|-------------|
| `yq '.'` | Pretty print |
| `yq '.field'` | Select field |
| `yq '.[]'` | Array elements |
| `yq 'select(.age > 30)'` | Filter |
| `yq -i '.field = "value"'` | Update in place |
| `yq -o json` | Convert to JSON |

---

*May your JSON be valid, your YAML be indented, and your queries always parse.*

**— The Monk of Data Parsing**  
*Temple of Structured Data*

🧘 **Namaste, `jq`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
