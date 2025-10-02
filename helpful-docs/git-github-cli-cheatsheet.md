# 🧘 The Enlightened Engineer's Git & GitHub CLI Scripture

> *"In the beginning was the Commit, and the Commit was with Git, and the Commit was Git."*  
> — **The Monk of Merges**, *Book of Branches, Chapter 1:1*

Greetings, fellow traveler on the path of version control enlightenment. I am but a humble monk who has meditated upon the sacred texts of Torvalds and witnessed the dance of distributed repositories across countless moons.

This scripture shall guide you through the mystical arts of Git and the GitHub CLI (`gh`), with the precision of a master's brush stroke and the wit of a caffeinated hermit.

---

## 📿 Table of Sacred Knowledge

1. [Git Configuration & Setup](#-git-configuration--setup)
2. [Git Basics](#-git-basics-the-foundation)
3. [Branching](#-branching-the-many-paths)
4. [Staging & Committing](#-staging--committing-the-art-of-intention)
5. [Remote Operations](#-remote-operations-beyond-your-mountain)
6. [History & Inspection](#-history--inspection-reading-the-scrolls)
7. [Merging & Rebasing](#-merging--rebasing-the-dance-of-integration)
8. [Stashing](#-stashing-the-hidden-cache)
9. [Undoing & Rewriting](#-undoing--rewriting-the-path-of-correction)
10. [Tags](#-tags-marking-sacred-milestones)
11. [Advanced Git](#-advanced-git-techniques)
12. [GitHub CLI](#-github-cli-gh-the-modern-mystic)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Git Configuration & Setup

*Before the journey begins, one must prepare their temple.*

### Initial Configuration
```bash
# Set identity (required)
git config --global user.name "Master Shifu"
git config --global user.email "shifu@monastery.dev"

# Set default branch
git config --global init.defaultBranch main

# Set editor
git config --global core.editor "vim"
git config --global core.editor "code --wait"
```

### Essential Config for the Enlightened
```bash
# Better merge conflict resolution
git config --global merge.conflictstyle diff3
git config --global diff.algorithm histogram

# CRLF handling
git config --global core.autocrlf input  # Linux/Mac
git config --global core.autocrlf true   # Windows

# Auto-color output
git config --global color.ui auto

# Rebase on pull (cleaner history)
git config --global pull.rebase true

# Auto-prune deleted branches
git config --global fetch.prune true

# Credential caching
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
```

### Powerful Aliases (The Shortcuts of the Wise)
```bash
# Status & branch
git config --global alias.st "status"
git config --global alias.s "status -sb"
git config --global alias.br "branch"
git config --global alias.co "checkout"
git config --global alias.cob "checkout -b"

# Commit shortcuts
git config --global alias.ci "commit"
git config --global alias.cm "commit -m"
git config --global alias.ca "commit --amend"
git config --global alias.cane "commit --amend --no-edit"

# Beautiful logs
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.last "log -1 HEAD"

# Diff aliases
git config --global alias.df "diff"
git config --global alias.dfc "diff --cached"
git config --global alias.dfstat "diff --stat"

# Undo operations
git config --global alias.unstage "reset HEAD --"
git config --global alias.undo "reset --soft HEAD^"

# Find commits
git config --global alias.find "log --all --oneline --grep"
git config --global alias.contributors "shortlog -sn"

# View config
git config --list
git config --list --show-origin
git config --global --edit
```

---

## 🌱 Git Basics: The Foundation

*Every grand repository begins with a single init.*

### Repository Initialization
```bash
# Create new repo
git init
git init my-project

# Clone existing repo
git clone https://github.com/user/repo.git
git clone https://github.com/user/repo.git my-dir

# Clone specific branch
git clone -b develop https://github.com/user/repo.git

# Shallow clone (recent history only)
git clone --depth 1 https://github.com/user/repo.git

# Clone with submodules
git clone --recursive https://github.com/user/repo.git
```

### Status & Help
```bash
# Check status
git status
git status -s  # Short format
git status -sb # Short with branch

# Get help
git help <command>
git <command> --help
git <command> -h  # Quick help
```

---

## 🌿 Branching: The Many Paths

*Like a river splitting into streams, so too must your code diverge to find its way.*

### Creating & Switching Branches
```bash
# Create branch (stay on current)
git branch feature/enlightenment

# Create and switch (old way)
git checkout -b feature/enlightenment

# Create and switch (modern - Git 2.23+)
git switch -c feature/enlightenment

# Create from specific commit
git branch feature/fix a1b2c3d

# Switch branches
git checkout main
git switch main        # Modern way
git checkout -         # Switch to previous branch
git switch -
```

### Listing Branches
```bash
# Local branches
git branch
git branch -v          # With last commit
git branch -vv         # With tracking info

# All branches (local + remote)
git branch -a

# Remote only
git branch -r

# Merged/unmerged
git branch --merged
git branch --no-merged

# Search branches
git branch --list "feature/*"
git branch --contains a1b2c3d
```

### Renaming & Deleting
```bash
# Rename current branch
git branch -m new-name

# Rename specific branch
git branch -m old-name new-name

# Delete local branch
git branch -d feature/done       # Safe
git branch -D feature/abandon    # Force

# Delete remote branch
git push origin --delete feature/old
git push origin :feature/old     # Old way

# Prune deleted remote branches
git fetch --prune
git remote prune origin
```

---

## 🎭 Staging & Committing: The Art of Intention

*A commit is a promise to your future self. Choose wisely.*

### Adding to Staging
```bash
# Add specific files
git add file1.txt file2.txt
git add src/

# Add all changes
git add .
git add -A
git add --all

# Add modified/deleted only (not new)
git add -u

# Interactive add
git add -i

# Patch mode (stage parts)
git add -p
```

### Committing
```bash
# Commit with message
git commit -m "Add feature"

# Commit all tracked files
git commit -am "Fix bug"

# Open editor for detailed message
git commit

# Commit with specific author
git commit --author="Monk <monk@temple.dev>" -m "Message"

# Commit with specific date
git commit --date="2024-01-01" -m "Message"

# GPG sign commit
git commit -S -m "Signed commit"
```

### Amending Commits
```bash
# Amend last commit
git commit --amend

# Amend without changing message
git commit --amend --no-edit

# Add forgotten file to last commit
git add forgotten.txt
git commit --amend --no-edit
```

### Unstaging & Discarding
```bash
# Unstage file
git restore --staged file.txt   # Modern
git reset HEAD file.txt          # Old way

# Discard working changes
git restore file.txt             # Modern
git checkout -- file.txt         # Old way

# Discard all changes
git restore .
git reset --hard HEAD            # Nuclear option
```

---

## 🌍 Remote Operations: Beyond Your Mountain

*The monastery connects to the world through invisible threads.*

### Managing Remotes
```bash
# Show remotes
git remote
git remote -v

# Add remote
git remote add origin https://github.com/user/repo.git
git remote add upstream https://github.com/upstream/repo.git

# Change URL
git remote set-url origin https://github.com/user/new-repo.git

# Rename/remove
git remote rename origin upstream
git remote remove origin

# Show remote info
git remote show origin
```

### Fetch, Pull, Push
```bash
# Fetch
git fetch
git fetch origin
git fetch --all
git fetch --prune

# Pull
git pull
git pull origin main
git pull --rebase            # Rebase instead of merge
git pull --ff-only           # Fast-forward only

# Push
git push
git push origin main
git push -u origin feature   # Set upstream
git push --all               # All branches
git push --tags              # Push tags

# Force push (dangerous!)
git push --force
git push --force-with-lease  # Safer

# Delete remote branch
git push origin --delete feature/old
```

### Tracking Branches
```bash
# Show tracking
git branch -vv

# Set upstream
git branch -u origin/main
git push -u origin feature

# Unset upstream
git branch --unset-upstream
```

---

## 📜 History & Inspection: Reading the Scrolls

*To understand where you're going, first understand where you've been.*

### Viewing Log
```bash
# Basic log
git log
git log --oneline
git log -n 5           # Last 5 commits

# Beautiful graph
git log --graph --oneline --all
git log --graph --pretty=format:'%h -%d %s (%cr) <%an>'

# With file changes
git log --stat
git log -p             # Full diffs

# Filter by date
git log --since="2024-01-01"
git log --until="2024-12-31"
git log --after="2 weeks ago"

# Filter by author
git log --author="Monk"

# Filter by message
git log --grep="bug fix"

# File history
git log -- path/to/file.txt
git log --follow -- file.txt  # Follow renames

# Merge commits
git log --merges
git log --no-merges

# Branch comparison
git log main..feature          # In feature but not main
git log main...feature         # In either but not both
```

### Searching & Inspecting
```bash
# Show commit
git show a1b2c3d
git show a1b2c3d:path/file.txt

# Blame (who changed what)
git blame file.txt
git blame -L 10,20 file.txt    # Line range

# Search code
git grep "function"
git grep -n "function"         # With line numbers
git grep "function" a1b2c3d    # In specific commit

# Diff
git diff                        # Unstaged
git diff --cached              # Staged
git diff HEAD                  # All changes
git diff a1b2c3d b2c3d4e       # Between commits
git diff main..feature         # Between branches
git diff --word-diff           # Word-level
git diff --stat                # Stats only

# Reflog (time machine)
git reflog
git reflog show main
```

---

## 🔀 Merging & Rebasing: The Dance of Integration

*Merge preserves history, rebase rewrites it.*

### Merging
```bash
# Merge branch into current
git merge feature/enlightenment

# Merge with message
git merge feature/enlightenment -m "Merge message"

# No fast-forward (always create merge commit)
git merge --no-ff feature/enlightenment

# Fast-forward only
git merge --ff-only feature/enlightenment

# Squash all commits into one
git merge --squash feature/enlightenment

# Abort/continue
git merge --abort
git merge --continue
```

### Rebasing
```bash
# Rebase onto main
git rebase main

# Interactive rebase (edit history)
git rebase -i HEAD~5
git rebase -i main

# Continue/skip/abort
git rebase --continue
git rebase --skip
git rebase --abort

# Rebase onto different base
git rebase --onto main server client

# Auto-stash before rebase
git rebase --autostash main
```

### Interactive Rebase Commands
```
# In editor:
pick   = use commit
reword = change message
edit   = stop for amending
squash = meld into previous (keep message)
fixup  = meld into previous (discard message)
drop   = remove commit
exec   = run command

# Example: squash last 3 commits
git rebase -i HEAD~3
# Change "pick" to "fixup" for commits 2-3
```

### Conflict Resolution
```bash
# Show conflicts
git status
git diff

# Accept theirs/ours
git checkout --theirs file.txt
git checkout --ours file.txt

# Use merge tool
git mergetool

# Mark resolved
git add file.txt
git merge --continue
```

### Cherry-Picking
```bash
# Apply commit to current branch
git cherry-pick a1b2c3d

# Multiple commits
git cherry-pick a1b2c3d b2c3d4e

# Without committing
git cherry-pick -n a1b2c3d

# Edit message
git cherry-pick -e a1b2c3d

# Continue/abort
git cherry-pick --continue
git cherry-pick --abort
```

---

## 📦 Stashing: The Hidden Cache

*Set aside work temporarily, like a monk pausing meditation.*

```bash
# Stash changes
git stash
git stash push -m "WIP: feature"

# Include untracked/ignored
git stash -u               # Untracked
git stash -a               # All (including ignored)

# Stash specific files
git stash push file1.txt file2.txt

# Patch mode (choose what to stash)
git stash -p

# List stashes
git stash list

# Show stash
git stash show
git stash show -p          # Full diff
git stash show stash@{1}

# Apply stash (keep in list)
git stash apply
git stash apply stash@{2}

# Pop stash (apply and remove)
git stash pop
git stash pop stash@{1}

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear

# Create branch from stash
git stash branch feature/from-stash
```

---

## ⏮ Undoing & Rewriting: The Path of Correction

*Even masters make mistakes. The wise know how to unmake them.*

### Undo Changes
```bash
# Discard file changes
git restore file.txt
git checkout -- file.txt     # Old way

# Discard all changes
git restore .

# Restore from specific commit
git restore --source=a1b2c3d file.txt
```

### Undo Commits
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (unstage changes)
git reset HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo multiple commits
git reset --soft HEAD~3

# Revert (create new commit that undoes)
git revert a1b2c3d
git revert a1b2c3d..b2c3d4e

# Revert merge commit
git revert -m 1 merge-hash
```

### Rewrite History
```bash
# Change last commit message
git commit --amend -m "New message"

# Change last commit author
git commit --amend --author="New <new@email.com>" --no-edit

# Interactive rebase to rewrite
git rebase -i HEAD~5

# Remove file from all history
git filter-repo --path secrets.txt --invert-paths
```

### Recover Lost Work
```bash
# View reflog
git reflog

# Recover deleted branch
git checkout -b recovered a1b2c3d

# Reset to previous state
git reset --hard HEAD@{5}

# Find lost commits
git fsck --lost-found
```

---

## 🏷 Tags: Marking Sacred Milestones

*Stone markers on the path of progress.*

```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag (recommended)
git tag -a v1.0.0 -m "Release 1.0.0"

# Tag specific commit
git tag -a v1.0.0 a1b2c3d -m "Release 1.0.0"

# List tags
git tag
git tag -l "v1.*"
git tag -n              # With messages

# Show tag
git show v1.0.0

# Push tags
git push origin v1.0.0
git push --tags
git push --follow-tags  # Annotated only

# Delete tags
git tag -d v1.0.0
git push origin --delete v1.0.0

# Checkout tag
git checkout v1.0.0
git checkout -b version-1 v1.0.0
```

---

## 🔮 Advanced Git Techniques

*For those seeking deeper wisdom.*

### Submodules
```bash
# Add submodule
git submodule add https://github.com/user/lib.git libs/lib

# Init & update after clone
git submodule init
git submodule update

# Clone with submodules
git clone --recursive https://github.com/user/repo.git

# Update submodules
git submodule update --remote
git submodule update --recursive

# Run command in all submodules
git submodule foreach 'git pull'

# Remove submodule
git submodule deinit libs/lib
git rm libs/lib
rm -rf .git/modules/libs/lib
```

### Worktrees
```bash
# Create worktree (multiple checkouts)
git worktree add ../feature feature/branch

# List worktrees
git worktree list

# Remove worktree
git worktree remove ../feature
git worktree prune
```

### Bisect (Find Bug Introduction)
```bash
# Start bisecting
git bisect start
git bisect bad              # Current is bad
git bisect good a1b2c3d     # Known good commit

# Test and mark
git bisect good  # or git bisect bad

# Reset when done
git bisect reset

# Automated bisect
git bisect run ./test.sh
```

### Maintenance
```bash
# Garbage collection
git gc
git gc --aggressive

# Verify integrity
git fsck

# Repository stats
git count-objects -v

# Clean untracked files
git clean -n               # Dry run
git clean -f               # Remove files
git clean -fd              # Remove files and dirs
git clean -fdx             # Include ignored files
```

---

## 🚀 GitHub CLI (gh): The Modern Mystic

*Bringing GitHub to your terminal.*

### Setup
```bash
# Install
# macOS: brew install gh
# Linux: See https://cli.github.com/
# Windows: winget install GitHub.cli

# Authenticate
gh auth login
gh auth status
gh auth refresh
```

### Repository Operations
```bash
# Create repo
gh repo create my-repo --public --clone
gh repo create my-repo --private --description "My project"

# Clone
gh repo clone user/repo

# View repo
gh repo view
gh repo view user/repo --web

# Fork repo
gh repo fork user/repo --clone

# List repos
gh repo list
gh repo list user

# Sync fork
gh repo sync user/repo

# Archive repo
gh repo archive user/repo

# Delete repo
gh repo delete user/repo
```

### Pull Requests
```bash
# Create PR
gh pr create
gh pr create --title "Feature" --body "Description"
gh pr create --base main --head feature

# Create draft PR
gh pr create --draft

# List PRs
gh pr list
gh pr list --state open
gh pr list --author username

# View PR
gh pr view 123
gh pr view 123 --web

# Check out PR
gh pr checkout 123

# Review PR
gh pr review 123 --approve
gh pr review 123 --request-changes -b "Needs work"
gh pr review 123 --comment -b "Looks good"

# Merge PR
gh pr merge 123
gh pr merge 123 --squash
gh pr merge 123 --rebase
gh pr merge 123 --merge

# Close PR
gh pr close 123

# Reopen PR
gh pr reopen 123

# PR status checks
gh pr checks 123

# PR diff
gh pr diff 123
```

### Issues
```bash
# Create issue
gh issue create
gh issue create --title "Bug" --body "Description"

# List issues
gh issue list
gh issue list --state open
gh issue list --assignee username
gh issue list --label bug

# View issue
gh issue view 456
gh issue view 456 --web

# Close/reopen issue
gh issue close 456
gh issue reopen 456

# Comment on issue
gh issue comment 456 --body "Update"

# Edit issue
gh issue edit 456 --title "New title"
gh issue edit 456 --add-label "bug"
gh issue edit 456 --add-assignee username
```

### GitHub Actions
```bash
# List workflows
gh workflow list

# View workflow
gh workflow view
gh workflow view "CI"

# Run workflow
gh run list
gh run watch
gh run view 123

# Download artifacts
gh run download 123

# Re-run workflow
gh run rerun 123
```

### Releases
```bash
# Create release
gh release create v1.0.0
gh release create v1.0.0 --notes "Release notes"
gh release create v1.0.0 dist/* --notes "v1.0.0"

# List releases
gh release list

# View release
gh release view v1.0.0
gh release view --web

# Download release assets
gh release download v1.0.0

# Delete release
gh release delete v1.0.0
```

### Gists
```bash
# Create gist
gh gist create file.txt
gh gist create file.txt --public
gh gist create file.txt --desc "Description"

# List gists
gh gist list

# View gist
gh gist view ID

# Edit gist
gh gist edit ID

# Delete gist
gh gist delete ID
```

### Advanced gh
```bash
# GitHub API calls
gh api repos/user/repo
gh api user
gh api graphql -f query='...'

# Extensions
gh extension list
gh extension install owner/repo
gh extension upgrade --all

# Aliases
gh alias set pv 'pr view'
gh alias list

# Status
gh status

# Browse repo in web
gh browse
```

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Authentication Problems
```bash
# Check auth
gh auth status
git config credential.helper

# Re-authenticate
gh auth login
gh auth refresh

# SSH keys
ssh -T git@github.com
ssh-add -l

# Generate new SSH key
ssh-keygen -t ed25519 -C "your@email.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# Add to GitHub: gh ssh-key add ~/.ssh/id_ed25519.pub
```

#### Merge Conflicts
```bash
# Abort and start over
git merge --abort
git rebase --abort

# See conflicts
git diff --name-only --diff-filter=U

# Use theirs/ours for all
git checkout --theirs .
git checkout --ours .

# Re-merge with different strategy
git merge -s recursive -X theirs branch
```

#### Detached HEAD
```bash
# Save work from detached HEAD
git branch temp-branch

# Or commit and cherry-pick
git commit -m "Work"
git checkout main
git cherry-pick HEAD@{1}
```

#### Accidentally Deleted Branch
```bash
# Find commit hash
git reflog

# Recreate branch
git branch recovered-branch commit-hash
```

#### Large File Issues
```bash
# Remove from history
git filter-repo --path large-file --invert-paths

# Or use BFG
java -jar bfg.jar --strip-blobs-bigger-than 100M
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

#### Corrupted Repository
```bash
# Verify integrity
git fsck

# Clone again and copy work
git clone https://github.com/user/repo.git fresh-clone
# Copy uncommitted work from old repo
```

### Performance Tips
```bash
# Shallow clone for large repos
git clone --depth 1 --single-branch https://github.com/user/repo.git

# Partial clone (Git 2.22+)
git clone --filter=blob:none https://github.com/user/repo.git

# Sparse checkout (only some dirs)
git sparse-checkout init
git sparse-checkout set src/ docs/

# Faster status
git status -uno  # Don't show untracked

# Aggressive cleanup
git gc --aggressive --prune=now
git repack -a -d --depth=250 --window=250
```

### Debugging Git
```bash
# Verbose output
GIT_TRACE=1 git push
GIT_CURL_VERBOSE=1 git push

# Debug pack issues
GIT_TRACE_PACK_ACCESS=1 git command

# Debug performance
GIT_TRACE_PERFORMANCE=1 git command
```

---

## 🙏 Closing Wisdom

*The path of Git mastery is endless. These commands are but stepping stones.*

### Essential Daily Commands
```bash
# The monk's morning ritual
git status
git pull --rebase
git add .
git commit -m "Meaningful message"
git push

# The monk's evening reflection
git log --oneline -10
git status
git stash  # If needed
```

### Best Practices from the Monastery

1. **Commit Often**: Small, focused commits are easier to understand and revert
2. **Write Good Messages**: Future you will thank present you
3. **Pull Before Push**: Sync before sharing your work
4. **Branch Liberally**: Branches are cheap, mistakes are expensive
5. **Review Before Committing**: `git diff --cached` is your friend
6. **Never Rewrite Public History**: Only rebase/amend local commits
7. **Use .gitignore**: Don't commit secrets, dependencies, or build artifacts
8. **Tag Releases**: Mark important milestones
9. **Learn Your Editor**: Commit messages deserve care
10. **Read the Diff**: Before committing, always review your changes

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `git status` | Show working tree status |
| `git add .` | Stage all changes |
| `git commit -m "msg"` | Commit with message |
| `git push` | Push to remote |
| `git pull` | Fetch and merge |
| `git checkout -b name` | Create and switch branch |
| `git merge branch` | Merge branch into current |
| `git log --oneline` | View commit history |
| `git stash` | Temporarily save changes |
| `git reset --soft HEAD~1` | Undo last commit, keep changes |
| `gh pr create` | Create pull request |
| `gh repo view --web` | Open repo in browser |

### When in Doubt

```bash
# The universal answers
git status          # Where am I?
git log --oneline   # What happened?
git reflog          # What did I do?
git help <command>  # How do I...?
```

---

*May your commits be atomic, your merges conflict-free, and your deployments always successful.*

**— The Monk of Merges**  
*Monastery of Version Control*  
*Temple of Git*

🧘 **Namaste, `git`**

---

## 📚 Additional Resources

- [Official Git Documentation](https://git-scm.com/doc)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Git Flight Rules](https://github.com/k88hudson/git-flight-rules)
- [Oh Shit, Git!?!](https://ohshitgit.com/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*
