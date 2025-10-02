# 🧘 The Enlightened Engineer's Vim & Tmux Scripture

> *"In the beginning was the Terminal, and the Terminal was with Vim, and the Terminal was multiplexed."*  
> — **The Monk of Terminals**, *Book of Editors, Chapter 1:1*

This scripture covers Vim (the ubiquitous editor) and Tmux (terminal multiplexer).

---

## 📿 Vim - The Editor

### Modes
```
Normal Mode    - Navigate and manipulate text (ESC)
Insert Mode    - Insert text (i, a, o)
Visual Mode    - Select text (v, V, Ctrl+v)
Command Mode   - Execute commands (:)
```

### Basic Navigation
```
h, j, k, l     - Left, down, up, right
w              - Next word
b              - Previous word
0              - Start of line
$              - End of line
gg             - First line
G              - Last line
:n             - Go to line n
Ctrl+f         - Page down
Ctrl+b         - Page up
```

### Editing
```
i              - Insert before cursor
a              - Insert after cursor
o              - New line below
O              - New line above
x              - Delete character
dd             - Delete line
yy             - Copy line
p              - Paste after
P              - Paste before
u              - Undo
Ctrl+r         - Redo
.              - Repeat last command
```

### Search & Replace
```
/pattern       - Search forward
?pattern       - Search backward
n              - Next match
N              - Previous match
:%s/old/new/g  - Replace all
:%s/old/new/gc - Replace with confirmation
```

### Visual Mode
```
v              - Character visual mode
V              - Line visual mode
Ctrl+v         - Block visual mode
d              - Delete selection
y              - Copy selection
>              - Indent right
<              - Indent left
```

### File Operations
```
:w             - Save
:q             - Quit
:wq            - Save and quit
:q!            - Quit without saving
:e file        - Open file
:bn            - Next buffer
:bp            - Previous buffer
```

### Multiple Windows
```
:split         - Horizontal split
:vsplit        - Vertical split
Ctrl+w h/j/k/l - Navigate windows
Ctrl+w q       - Close window
```

### Essential .vimrc
```vim
" Basic settings
set number              " Line numbers
set relativenumber      " Relative line numbers
set tabstop=4          " Tab width
set shiftwidth=4       " Indent width
set expandtab          " Use spaces
set autoindent         " Auto indent
set smartindent        " Smart indent
set hlsearch           " Highlight search
set incsearch          " Incremental search
set ignorecase         " Case insensitive search
set smartcase          " Case sensitive if uppercase
syntax on              " Syntax highlighting
filetype plugin indent on
```

---

## 🖥️ Tmux - Terminal Multiplexer

### Sessions
```bash
tmux                   # Start new session
tmux new -s name       # Start named session
tmux ls                # List sessions
tmux attach -t name    # Attach to session
tmux kill-session -t name  # Kill session
```

### Prefix Key
```
Default: Ctrl+b (C-b)
All commands start with prefix
```

### Windows
```
C-b c              - Create window
C-b ,              - Rename window
C-b n              - Next window
C-b p              - Previous window
C-b 0-9            - Switch to window number
C-b &              - Kill window
C-b w              - List windows
```

### Panes
```
C-b %              - Split vertically
C-b "              - Split horizontally
C-b arrow          - Navigate panes
C-b o              - Next pane
C-b x              - Kill pane
C-b z              - Toggle pane zoom
C-b {              - Move pane left
C-b }              - Move pane right
C-b space          - Toggle layouts
```

### Copy Mode
```
C-b [              - Enter copy mode
Space              - Start selection
Enter              - Copy selection
C-b ]              - Paste
q                  - Exit copy mode
```

### Session Management
```
C-b d              - Detach from session
C-b $              - Rename session
C-b s              - List sessions
C-b (              - Previous session
C-b )              - Next session
```

### Configuration (~/.tmux.conf)
```bash
# Remap prefix to Ctrl+a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config
bind r source-file ~/.tmux.conf

# Enable mouse
set -g mouse on

# Start windows at 1
set -g base-index 1

# Vi mode
setw -g mode-keys vi

# Status bar
set -g status-position bottom
set -g status-bg colour234
set -g status-fg colour137
```

---

## 🔮 Common Workflows

### Vim: Quick Edit and Save
```
vim file.txt
i                  # Enter insert mode
(type text)
ESC                # Exit insert mode
:wq                # Save and quit
```

### Tmux: Development Session
```bash
# Create session
tmux new -s dev

# Split for editor and terminal
C-b %              # Vertical split
C-b arrow          # Navigate to right pane
C-b "              # Horizontal split

# Result: Editor left, terminal top-right, logs bottom-right
```

### Vim + Tmux: Perfect Pair
```bash
# In tmux session
C-b %              # Split vertically
# Left pane: vim
# Right pane: terminal for running code
```

---

## 🙏 Quick Reference

### Vim Essentials
| Command | Action |
|---------|--------|
| `i` | Insert mode |
| `ESC` | Normal mode |
| `:w` | Save |
| `:q` | Quit |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `/pattern` | Search |
| `u` | Undo |

### Tmux Essentials
| Command | Action |
|---------|--------|
| `C-b c` | New window |
| `C-b %` | Split vertical |
| `C-b "` | Split horizontal |
| `C-b arrow` | Navigate panes |
| `C-b d` | Detach |
| `C-b [` | Copy mode |

---

*May your edits be swift, your panes be organized, and your sessions never die.*

**— The Monk of Terminals**  
*Temple of CLI*

🧘 **Namaste, `vim`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
