# Keybindings Reference

All keyboard shortcuts defined across the dotfiles configuration.

---

## GNOME Desktop

| Shortcut | Description | Example |
|---|---|---|
| `Ctrl+Alt+T` | Open WezTerm terminal | Launch a new terminal window from any context |

---

## Zsh Shell

| Shortcut | Description | Example |
|---|---|---|
| `Ctrl+F` | Accept autosuggestion | Start typing `git status`, see grey suggestion, press `Ctrl+F` to accept it |

### Aliases

| Alias | Expands To | Example |
|---|---|---|
| `v` | `nvim` | `v main.py` - open a file in Neovim |
| `g` | `git` | `g log --oneline` |
| `gs` | `git status` | `gs` - check working tree status |
| `ga` | `git add` | `ga .` - stage all changes |
| `gc` | `git commit` | `gc -m "fix: typo"` |
| `gp` | `git push` | `gp` - push current branch |
| `gd` | `git diff` | `gd` - view unstaged changes |
| `rebuild` | `~/.dotfiles/rebuild.sh` | `rebuild` - apply NixOS flake changes |

---

## Herdr (Terminal Multiplexer)

**Prefix:** `Ctrl+B` - press this before any Herdr command.

| Shortcut | Description | Example |
|---|---|---|
| `Ctrl+B` | Enter prefix mode | Required before any Herdr command below |
| `prefix + c` | Create new tab | Open a second tab for a parallel task |
| `prefix + &` | Close current tab | Clean up a tab when done |
| `prefix + w` | Open workspace picker | Switch between named workspaces |
| `prefix + g` | Go to workspace/pane | Jump directly to a named pane |
| `prefix + h` | Focus pane left | Move focus to the left split |
| `prefix + j` | Focus pane down | Move focus to the pane below |
| `prefix + k` | Focus pane up | Move focus to the pane above |
| `prefix + l` | Focus pane right | Move focus to the right split |
| `prefix + %` | Split pane vertically | Open a new pane side-by-side |
| `prefix + "` | Split pane horizontally | Open a new pane above/below |
| `prefix + y` | Enter copy mode | Scroll up through terminal output |

---

## Neovim

**Leader:** `Space` - used as prefix for most custom bindings.

### Core Bindings

| Shortcut | Mode | Description | Example |
|---|---|---|---|
| `Esc` | Normal | Autosave the current file | Press `Esc` after editing to instantly save |
| `Ctrl+A` | Normal | Select all text | `Ctrl+A` then `y` to copy entire file |
| `p` | Visual | Paste over selection without losing clipboard | Select text, press `p` to replace without overwriting clipboard |

### Navigation (Snacks.nvim)

| Shortcut | Description | Example |
|---|---|---|
| `Space + f` | Open file picker | Fuzzy search all files in project |
| `Space + s` | Open grep picker | Search for a string across all files |
| `Space + b` | Open buffer picker | Switch between open files |
| `gd` | Go to LSP definition | Cursor on a function call, `gd` to jump to its definition |

### File Explorer (Oil.nvim)

| Shortcut | Description | Example |
|---|---|---|
| `Space + e` | Open file explorer | Browse and edit the directory tree like a buffer |

### Git (Neogit)

| Shortcut | Description | Example |
|---|---|---|
| `Space + g` | Open Neogit interface | Stage, commit, push - full git workflow without leaving Neovim |

### Discoverability

| Shortcut | Description | Example |
|---|---|---|
| `Space` (hold) | Show which-key popup | Press `Space` and wait to see all available leader bindings |

---

## Tmux

**Prefix:** `Ctrl+A` (changed from default `Ctrl+B`).

Tmux uses its defaults for navigation and window management. The `yank` plugin adds system clipboard integration, and `sensible` applies sane defaults (no config needed).

| Shortcut | Description | Example |
|---|---|---|
| `Ctrl+A` | Enter prefix mode | Required before any tmux command |
| Mouse | Click/drag to select/resize | Click a pane to focus it; drag borders to resize |

---

## Quick Reference Card

```
GNOME         Ctrl+Alt+T         Open terminal

ZSH           Ctrl+F             Accept suggestion

HERDR         Ctrl+B + ...
              c                  New tab
              &                  Close tab
              w                  Workspace picker
              g                  Go to pane
              h/j/k/l            Navigate panes
              %                  Split vertical
              "                  Split horizontal
              y                  Copy mode

NEOVIM        <Leader> = Space
              Esc                Save file
              Ctrl+A             Select all
              <Leader>f          File picker
              <Leader>s          Grep
              <Leader>b          Buffers
              <Leader>e          Explorer
              <Leader>g          Git (Neogit)
              gd                 Go to definition

TMUX          Ctrl+A + ...       (tmux defaults + mouse on)
```
