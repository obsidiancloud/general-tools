# 🧘 The Enlightened Engineer's Bash Scripting Scripture

> *"In the beginning was the Shell, and the Shell was with Bash, and the Shell was scripted."*  
> — **The Monk of Shells**, *Book of Scripts, Chapter 1:1*

Greetings, fellow traveler on the path of shell scripting enlightenment. I am but a humble monk who has meditated upon the sacred texts of Brian Fox and witnessed the dance of commands across countless terminals.

This scripture shall guide you through the mystical arts of Bash scripting, with the precision of a master's script and the wit of a caffeinated sysadmin.

---

## 📿 Table of Sacred Knowledge

1. [Bash Basics](#-bash-basics)
2. [Variables](#-variables)
3. [Arrays](#-arrays)
4. [Conditionals](#-conditionals)
5. [Loops](#-loops)
6. [Functions](#-functions)
7. [Input/Output](#-inputoutput)
8. [String Operations](#-string-operations)
9. [File Operations](#-file-operations)
10. [Process Management](#-process-management)
11. [Error Handling](#-error-handling)
12. [Best Practices](#-best-practices)

---

## 🛠 Bash Basics

### Shebang and Script Structure

```bash
#!/bin/bash
# Script description
# Author: Your Name
# Date: 2024-01-01

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Main script logic
main() {
    echo "Hello, World!"
}

main "$@"
```

### Running Scripts

```bash
# Make executable
chmod +x script.sh

# Run script
./script.sh
bash script.sh
source script.sh  # Run in current shell
. script.sh       # Same as source
```

---

## 📦 Variables

### Variable Assignment

```bash
# Basic assignment
name="John"
age=30
readonly PI=3.14159  # Read-only variable

# Command substitution
current_date=$(date +%Y-%m-%d)
files=$(ls -l)

# Arithmetic
count=$((5 + 3))
result=$((count * 2))

# Default values
${var:-default}      # Use default if var is unset
${var:=default}      # Set var to default if unset
${var:?error}        # Error if var is unset
${var:+value}        # Use value if var is set
```

### Special Variables

```bash
$0      # Script name
$1-$9   # Positional parameters
$#      # Number of arguments
$@      # All arguments as separate words
$*      # All arguments as single word
$?      # Exit status of last command
$$      # Process ID of script
$!      # PID of last background command
$_      # Last argument of previous command
```

### Environment Variables

```bash
export VAR="value"   # Export to child processes
unset VAR            # Remove variable

# Common environment variables
$HOME               # Home directory
$USER               # Current user
$PATH               # Command search path
$PWD                # Current directory
$OLDPWD             # Previous directory
$SHELL              # Current shell
```

---

## 📚 Arrays

### Indexed Arrays

```bash
# Declaration
fruits=("apple" "banana" "cherry")
numbers=(1 2 3 4 5)

# Access elements
echo ${fruits[0]}        # First element
echo ${fruits[@]}        # All elements
echo ${fruits[*]}        # All elements as string
echo ${#fruits[@]}       # Array length

# Add elements
fruits+=("date")
fruits[3]="elderberry"

# Iterate
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Slice
echo ${fruits[@]:1:2}    # Elements 1-2
```

### Associative Arrays

```bash
# Declaration
declare -A colors
colors[red]="#FF0000"
colors[green]="#00FF00"
colors[blue]="#0000FF"

# Access
echo ${colors[red]}

# Keys and values
echo ${!colors[@]}       # All keys
echo ${colors[@]}        # All values

# Iterate
for key in "${!colors[@]}"; do
    echo "$key: ${colors[$key]}"
done
```

---

## 🔀 Conditionals

### If Statements

```bash
# Basic if
if [ "$age" -gt 18 ]; then
    echo "Adult"
fi

# If-else
if [ "$age" -gt 18 ]; then
    echo "Adult"
else
    echo "Minor"
fi

# If-elif-else
if [ "$age" -lt 13 ]; then
    echo "Child"
elif [ "$age" -lt 18 ]; then
    echo "Teenager"
else
    echo "Adult"
fi

# Multiple conditions
if [ "$age" -gt 18 ] && [ "$age" -lt 65 ]; then
    echo "Working age"
fi

if [ "$age" -lt 18 ] || [ "$age" -gt 65 ]; then
    echo "Not working age"
fi
```

### Test Operators

```bash
# Numeric comparisons
-eq     # Equal
-ne     # Not equal
-gt     # Greater than
-ge     # Greater than or equal
-lt     # Less than
-le     # Less than or equal

# String comparisons
=       # Equal
!=      # Not equal
-z      # Empty string
-n      # Not empty string

# File tests
-e      # Exists
-f      # Regular file
-d      # Directory
-r      # Readable
-w      # Writable
-x      # Executable
-s      # Not empty
-L      # Symbolic link

# Examples
if [ -f "/etc/passwd" ]; then
    echo "File exists"
fi

if [ -d "/var/log" ]; then
    echo "Directory exists"
fi

if [ -z "$var" ]; then
    echo "Variable is empty"
fi
```

### Case Statements

```bash
case "$1" in
    start)
        echo "Starting service"
        ;;
    stop)
        echo "Stopping service"
        ;;
    restart)
        echo "Restarting service"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

---

## 🔁 Loops

### For Loops

```bash
# Iterate over list
for item in apple banana cherry; do
    echo "$item"
done

# Iterate over array
fruits=("apple" "banana" "cherry")
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# C-style for loop
for ((i=0; i<10; i++)); do
    echo "$i"
done

# Iterate over files
for file in *.txt; do
    echo "Processing $file"
done

# Iterate over command output
for user in $(cat /etc/passwd | cut -d: -f1); do
    echo "User: $user"
done
```

### While Loops

```bash
# Basic while
count=0
while [ $count -lt 5 ]; do
    echo "Count: $count"
    ((count++))
done

# Read file line by line
while IFS= read -r line; do
    echo "$line"
done < file.txt

# Infinite loop
while true; do
    echo "Running..."
    sleep 1
done
```

### Until Loops

```bash
count=0
until [ $count -ge 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### Loop Control

```bash
# Break
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        break
    fi
    echo "$i"
done

# Continue
for i in {1..10}; do
    if [ $i -eq 5 ]; then
        continue
    fi
    echo "$i"
done
```

---

## 🔧 Functions

### Function Definition

```bash
# Method 1
function greet() {
    echo "Hello, $1!"
}

# Method 2
greet() {
    echo "Hello, $1!"
}

# Call function
greet "World"
```

### Function Parameters

```bash
process_file() {
    local filename="$1"
    local mode="${2:-read}"  # Default value
    
    echo "Processing $filename in $mode mode"
}

process_file "data.txt" "write"
```

### Return Values

```bash
# Return exit status
is_valid() {
    if [ "$1" -gt 0 ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

if is_valid 5; then
    echo "Valid"
fi

# Return string via echo
get_username() {
    echo "john_doe"
}

username=$(get_username)
```

---

## 📥 Input/Output

### Reading Input

```bash
# Read user input
read -p "Enter your name: " name
echo "Hello, $name"

# Read with timeout
read -t 5 -p "Enter (5 sec timeout): " input

# Read password (hidden)
read -s -p "Enter password: " password

# Read into array
read -a words <<< "one two three"
```

### Output

```bash
# Echo
echo "Hello, World!"
echo -n "No newline"
echo -e "Line 1\nLine 2"  # Interpret escapes

# Printf
printf "Name: %s, Age: %d\n" "John" 30
printf "%.2f\n" 3.14159

# Redirect output
echo "text" > file.txt       # Overwrite
echo "text" >> file.txt      # Append
echo "error" >&2             # To stderr

# Here document
cat << EOF
Line 1
Line 2
EOF

# Here string
grep "pattern" <<< "text to search"
```

---

## 🔤 String Operations

### String Manipulation

```bash
str="Hello, World!"

# Length
${#str}                      # 13

# Substring
${str:0:5}                   # "Hello"
${str:7}                     # "World!"

# Replace
${str/World/Bash}            # Replace first
${str//o/0}                  # Replace all

# Remove prefix/suffix
${str#Hello, }               # Remove shortest prefix
${str##*/}                   # Remove longest prefix
${str%!}                     # Remove shortest suffix
${str%%,*}                   # Remove longest suffix

# Case conversion
${str^^}                     # Uppercase
${str,,}                     # Lowercase
${str~}                      # Toggle first char
${str~~}                     # Toggle all chars
```

### String Comparison

```bash
if [ "$str1" = "$str2" ]; then
    echo "Equal"
fi

if [ "$str1" != "$str2" ]; then
    echo "Not equal"
fi

# Pattern matching
if [[ "$str" == *"pattern"* ]]; then
    echo "Contains pattern"
fi

if [[ "$str" =~ ^[0-9]+$ ]]; then
    echo "Is number"
fi
```

---

## 📁 File Operations

### File Tests

```bash
if [ -e "$file" ]; then echo "Exists"; fi
if [ -f "$file" ]; then echo "Regular file"; fi
if [ -d "$dir" ]; then echo "Directory"; fi
if [ -r "$file" ]; then echo "Readable"; fi
if [ -w "$file" ]; then echo "Writable"; fi
if [ -x "$file" ]; then echo "Executable"; fi
if [ -s "$file" ]; then echo "Not empty"; fi
if [ -L "$link" ]; then echo "Symbolic link"; fi
```

### File Operations

```bash
# Create file
touch file.txt

# Create directory
mkdir -p /path/to/dir

# Copy
cp source.txt dest.txt
cp -r source_dir dest_dir

# Move/Rename
mv old.txt new.txt

# Delete
rm file.txt
rm -rf directory

# Find files
find /path -name "*.txt"
find /path -type f -mtime -7  # Modified in last 7 days

# Read file
while IFS= read -r line; do
    echo "$line"
done < file.txt

# Write file
echo "content" > file.txt
cat > file.txt << EOF
Line 1
Line 2
EOF
```

---

## ⚙️ Process Management

### Running Commands

```bash
# Run in background
command &

# Wait for background jobs
wait

# Get PID
pid=$!

# Kill process
kill $pid
kill -9 $pid  # Force kill

# Check if process running
if ps -p $pid > /dev/null; then
    echo "Running"
fi
```

### Command Chaining

```bash
# AND
command1 && command2

# OR
command1 || command2

# Pipe
command1 | command2

# Redirect
command > file.txt 2>&1
command &> file.txt  # Same as above
```

---

## ⚠️ Error Handling

### Exit Codes

```bash
# Exit with code
exit 0  # Success
exit 1  # Error

# Check last exit code
if [ $? -eq 0 ]; then
    echo "Success"
fi
```

### Error Handling

```bash
# Exit on error
set -e

# Exit on undefined variable
set -u

# Exit on pipe failure
set -o pipefail

# Combine
set -euo pipefail

# Trap errors
trap 'echo "Error on line $LINENO"' ERR

# Cleanup on exit
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}
trap cleanup EXIT
```

---

## ✅ Best Practices

### Script Template

```bash
#!/bin/bash
#
# Script: backup.sh
# Description: Backup files to remote server
# Author: Your Name
# Date: 2024-01-01
#

set -euo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="/var/backups"
readonly LOG_FILE="/var/log/backup.log"

# Functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $*" >&2
    exit 1
}

cleanup() {
    log "Cleaning up temporary files"
    rm -f /tmp/backup_*
}

backup_files() {
    local source="$1"
    local dest="$2"
    
    log "Backing up $source to $dest"
    rsync -av "$source" "$dest" || error "Backup failed"
}

main() {
    log "Starting backup"
    
    # Check prerequisites
    command -v rsync >/dev/null 2>&1 || error "rsync not found"
    
    # Perform backup
    backup_files "/home" "$BACKUP_DIR"
    
    log "Backup completed successfully"
}

# Trap cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
```

### Best Practices

```bash
# 1. Use quotes around variables
echo "$var"
rm "$file"

# 2. Use [[ ]] instead of [ ]
if [[ "$var" == "value" ]]; then
    echo "Match"
fi

# 3. Use $() instead of backticks
result=$(command)

# 4. Check command existence
if command -v git >/dev/null 2>&1; then
    echo "Git is installed"
fi

# 5. Use local variables in functions
function my_func() {
    local var="value"
}

# 6. Use readonly for constants
readonly PI=3.14159

# 7. Use arrays for lists
files=("file1.txt" "file2.txt")
for file in "${files[@]}"; do
    echo "$file"
done

# 8. Use shellcheck
# Install: sudo apt install shellcheck
# Run: shellcheck script.sh
```

---

## 🙏 Closing Wisdom

### Quick Reference

| Operation | Syntax |
|-----------|--------|
| Variable | `var="value"` |
| Command substitution | `$(command)` |
| Arithmetic | `$((expr))` |
| If statement | `if [ cond ]; then ... fi` |
| For loop | `for i in list; do ... done` |
| While loop | `while [ cond ]; do ... done` |
| Function | `func() { ... }` |
| Array | `arr=(1 2 3)` |
| String length | `${#str}` |
| Substring | `${str:pos:len}` |

---

*May your scripts be robust, your variables be quoted, and your exit codes always zero.*

**— The Monk of Shells**  
*Monastery of Automation*  
*Temple of Bash*

🧘 **Namaste, `bash`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*  
*Bash Version: 5.0+*
