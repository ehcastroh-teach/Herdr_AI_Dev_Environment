# Herdr AI Dev Environment

A fully declarative, reproducible development environment for building with AI coding agents, authored in NixOS and Nix Flakes. This repo teaches you how to express your entire operating system - the OS, shell, editor, terminal multiplexer, and AI agent rules - as version-controlled code so that one command rebuilds the whole stack on any machine and a single rollback undoes any agent-introduced breakage.

---

## Learning Objectives

- Understand the two-layer NixOS architecture: system configuration (`configuration.nix`) versus user environment (Home Manager via `home.nix`).
- Pin a complete software stack to exact versions using Nix Flakes and `flake.lock`, then upgrade deliberately rather than reactively.
- Declare symlinks in `home.nix` so that config files living inside this repo are the source of truth for every tool, eliminating "it works on my machine" drift.
- Write a single shared agent memory file (`AGENTS.md`) and symlink it to every AI coding agent harness (Claude Code, Codex, OpenCode) so all agents share the same behavioral rules without duplication.
- Configure Herdr, a terminal multiplexer built for AI agent workflows, using a declarative TOML file committed to the repo.
- Run local language models (Ollama, llama.cpp) and download models from HuggingFace Hub, all wired into the same NixOS configuration.
- Perform safe system upgrades and rollbacks using `nixos-rebuild` and NixOS generations.

---

## Data / File Dictionary

| File or Directory | Description |
|---|---|
| `flake.nix` | Entry point - declares all external inputs (nixpkgs, Home Manager, Herdr, VoxType) and wires them into the system configuration |
| `flake.lock` | Exact commit hashes for every flake input - the reproducibility guarantee |
| `configuration.nix` | System-layer config: boot, networking, GNOME, NVIDIA, audio, swap, fonts, and all system packages |
| `home.nix` | User-layer config (Home Manager): shell, git, starship prompt, editor, and symlinks from `config/` into `~/.config/` |
| `hardware-configuration.nix` | Auto-generated per machine - disk UUIDs and kernel modules; never share between machines |
| `rebuild.sh` | One-liner that runs `sudo nixos-rebuild switch --flake .` from the correct directory |
| `config/herdr/config.toml` | Herdr terminal multiplexer settings: prefix key, pane keybindings, theme, UI, and session options |
| `config/nvim/` | Neovim configuration using lazy.nvim plugin manager with snacks, neogit, and oil |
| `config/wezterm/wezterm.lua` | WezTerm terminal emulator config: Rose Pine Moon theme, Hack Nerd Font |
| `config/claude/settings.json` | Claude Code CLI settings (symlinked by Home Manager to `~/.claude/settings.json`) |
| `config/voxtype/` | VoxType voice dictation daemon configuration |
| `home/AGENTS.md` | Shared behavioral rules for all AI coding agents - symlinked to Claude, Codex, and OpenCode harnesses |
| `nix/ollama.nix` | Optional module to enable the Ollama local model server with CUDA acceleration |
| `nix/llama-cpp.nix` | Optional module to install llama.cpp with CUDA support for direct GGUF model inference |
| `nix/huggingface-cli.nix` | Optional module to install the HuggingFace Hub CLI for downloading models |
| `docs/keybindings.md` | Full keybindings reference for GNOME, Zsh, Herdr, Neovim, and tmux with examples |
| `docs/keybindings.png` | Visual keybindings reference card |

---

## Workflow Diagram

```
Fresh NixOS install
        |
        v
Enable flakes in /etc/nixos/configuration.nix
        |
        v
Clone this repo -> ln -sfn ~/Projects/dotfiles ~/.dotfiles
        |
        v
Copy hardware-configuration.nix (machine-specific, never shared)
        |
        v
sudo nixos-rebuild switch --flake .
        |
        +---> configuration.nix applied (system packages, GNOME, NVIDIA, fonts)
        |
        +---> home.nix applied via Home Manager
                |
                +---> Shell: zsh + starship + aliases
                +---> Git config
                +---> Symlinks: config/ -> ~/.config/ (nvim, wezterm, herdr, claude)
                +---> Agent memory: home/AGENTS.md -> ~/.claude/CLAUDE.md
                                                    -> ~/.codex/AGENTS.md
                                                    -> ~/.config/opencode/AGENTS.md
        |
        v
Open WezTerm (Ctrl+Alt+T)
Open Herdr (prefix: Ctrl+B)
Launch nvim (lazy.nvim bootstraps plugins on first run)
Run claude, codex, or opencode - all share the same behavioral rules
```

---

## Step-by-Step Walkthrough

### Step 1 - Separate system and user concerns

NixOS splits its configuration into two distinct layers. `configuration.nix` owns everything that requires root - the bootloader, networking, hardware drivers, system-wide packages, and services like GNOME and PipeWire. `home.nix` (managed by the Home Manager module) owns everything that belongs to a single user - the shell, the editor, git identity, and where config files live.

This separation matters because it makes the system auditable: you can read `configuration.nix` and know exactly which services are running, and read `home.nix` and know exactly what the user environment looks like. Nothing is configured ad-hoc in shell scripts that run once and are forgotten.

### Step 2 - Pin inputs with Nix Flakes

The `flake.nix` file declares every external dependency by URL. When you run `nixos-rebuild switch` for the first time, Nix resolves those URLs to exact git commit hashes and writes them into `flake.lock`. Every subsequent build reads from `flake.lock` rather than the network, so the build is byte-for-byte reproducible regardless of when it runs.

The flake uses two nixpkgs channels simultaneously: `nixpkgs` tracks `nixos-25.11` (stable) for the system, while `nixpkgs-unstable` provides a more recent Neovim and Herdr. This pattern - stable base, unstable edge for specific tools - balances reliability with access to current versions of fast-moving tooling.

### Step 3 - Make config files the source of truth via symlinks

Instead of copying config files to `~/.config/`, `home.nix` uses `mkOutOfStoreSymlink` to point each tool's expected config location back at the file inside this repo:

```
~/.config/herdr  ->  ~/.dotfiles/config/herdr
~/.config/nvim   ->  ~/.dotfiles/config/nvim
~/.config/wezterm -> ~/.dotfiles/config/wezterm
```

The consequence is that editing `config/wezterm/wezterm.lua` takes effect the moment WezTerm reloads - no rebuild needed. Only changes to `.nix` files require running `rebuild`. This two-tier feedback loop (instant for config, rebuild for system) is a deliberate design choice that keeps iteration fast without sacrificing reproducibility.

### Step 4 - Share agent rules across all AI coding tools

`home/AGENTS.md` is the single source of truth for how every AI agent in this environment behaves. Home Manager symlinks it to three locations simultaneously:

- `~/.claude/CLAUDE.md` - read by Claude Code
- `~/.codex/AGENTS.md` - read by Codex
- `~/.config/opencode/AGENTS.md` - read by OpenCode

This means changing one file propagates behavioral rules to all agents without any manual synchronization. The file contains style rules, commit conventions, and decision-making priorities that the agents apply to every project they touch.

For project-specific context, create a separate `AGENTS.md` in the project root (describing what the project is, not how agents should behave), then symlink `CLAUDE.md -> AGENTS.md` in that same root. The two layers stack: agents load both global behavior rules and project-specific context.

### Step 5 - Configure Herdr as the agent-aware multiplexer

Herdr is a terminal multiplexer designed with AI coding agents in mind. Its sidebar tracks agent state across workspaces, so you can see at a glance which agent sessions are waiting for input, which are working, and which have finished - without switching tabs to check.

`config/herdr/config.toml` sets the prefix key to `Ctrl+B` and binds navigation to vim-style `h/j/k/l` keys for pane focus. The agent panel sorts by workspace (`agent_panel_sort = "spaces"`) so agents stay visually grouped with the project they belong to. Most other options are commented out with explanations, making the file serve as living documentation of what is configurable.

### Step 6 - Add local AI inference optionally

Three NixOS modules in `nix/` are imported by `configuration.nix` but can be toggled independently:

- `ollama.nix` - runs an Ollama server with CUDA acceleration and can pre-pull models (e.g., `gemma3:4b`) at activation time
- `llama-cpp.nix` - installs the llama.cpp CLI built with CUDA support for direct inference against GGUF model files
- `huggingface-cli.nix` - installs the HuggingFace Hub Python CLI for downloading models to local storage

Factoring these into separate files rather than inlining them in `configuration.nix` means you can comment out a single import line to remove a capability entirely, and the change is obvious in version history.

### Step 7 - Apply changes safely

```bash
rebuild   # alias defined in home.nix
```

This runs `sudo nixos-rebuild switch --flake ~/.dotfiles`. NixOS does not overwrite the previous system - it builds the new configuration alongside the old one and creates a new boot entry. If the new configuration breaks something, you can reboot and select the previous generation from the bootloader menu. Weekly garbage collection (`nix.gc`) keeps generations older than 30 days from accumulating indefinitely, while preserving a full month of rollback targets.

---

## How to Run

### Prerequisites

- A machine running NixOS (or a fresh NixOS install)
- Flakes enabled in `/etc/nixos/configuration.nix`:
  ```nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  ```
- An NVIDIA GPU with driver >= 560 (for the open kernel module)

### Steps

```bash
# 1. Apply the stock config to get flakes enabled, if not already:
sudo nixos-rebuild switch

# 2. Clone the repo and create the stable symlink:
git clone git@github.com:ehcastroh-teach/Herdr_AI_Dev_Environment.git ~/Projects/dotfiles
ln -sfn ~/Projects/dotfiles ~/.dotfiles

# 3. Replace the hardware config with this machine's scan:
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hardware-configuration.nix

# 4. Edit home.nix to set your git identity:
#    programs.git.settings.user.email = "your@email.com"

# 5. Build the full environment:
cd ~/.dotfiles && sudo nixos-rebuild switch --flake .

# 6. After the build completes, open a new terminal.
#    Zsh + starship are now active. Launch tools:
wezterm        # GPU-accelerated terminal (or Ctrl+Alt+T from GNOME)
nvim           # Neovim (lazy.nvim bootstraps plugins on first run)
claude         # Claude Code (log in with your Anthropic account)
herdr          # Terminal multiplexer with agent sidebar
```

### Applying subsequent changes

```bash
# Config files (nvim, wezterm, herdr, claude) - no rebuild needed, edit directly:
v ~/.dotfiles/config/herdr/config.toml

# NixOS or Home Manager changes - rebuild required:
rebuild
```

---

## Key Concepts Glossary

**Nix Flake** - A Nix project format that declares all external dependencies in a `flake.nix` file and locks their exact versions in `flake.lock`, making builds reproducible across machines and over time.

**NixOS** - A Linux distribution where the entire operating system is described in declarative Nix expressions. System state is derived from configuration files rather than accumulated through package installs and manual edits.

**Home Manager** - A Nix tool that applies the same declarative philosophy to the user environment: shell settings, editor config, git identity, and dotfile symlinks are all declared in `home.nix` and applied atomically.

**Generation** - A complete, immutable snapshot of a NixOS system configuration. Every rebuild creates a new generation while preserving previous ones as bootable rollback targets.

**Symlink (mkOutOfStoreSymlink)** - A file system pointer from a tool's expected config path (e.g., `~/.config/nvim`) to the actual file inside the repo. Changes to the repo file take effect immediately without a rebuild, because the tool reads through the symlink.

**Agent memory** - A text file that an AI coding agent loads at startup to apply behavioral rules or project context. Claude Code reads `CLAUDE.md`, Codex and OpenCode read `AGENTS.md`. Symlinking one file to all three locations keeps rules in sync.

**Herdr** - A terminal multiplexer (similar in concept to tmux) designed for AI agent workflows. Its sidebar shows agent state across all workspaces, making it easier to manage multiple long-running agent sessions in parallel.

**Prefix key** - In terminal multiplexers, a key chord pressed before a command key to distinguish multiplexer commands from input sent to the running program. Herdr defaults to `Ctrl+B`; tmux in this repo uses `Ctrl+A`.

**CUDA** - NVIDIA's parallel computing platform. Several packages in this repo (`ollama`, `llama-cpp`) are built with CUDA support to accelerate AI inference on the NVIDIA GPU.

**Ollama** - A local server that manages and serves open-source language models (e.g., Llama, Gemma) over a REST API, enabling AI features without sending data to external services.

**llama.cpp** - A C++ implementation of LLaMA-style model inference that runs efficiently on consumer hardware. The GGUF model format it uses can be downloaded from HuggingFace Hub.

**direnv** - A shell extension that loads and unloads environment variables automatically when you enter and leave a directory. Combined with `nix-direnv`, it provides per-project Nix development environments without polluting the global shell.

**stateVersion** - A value in both `configuration.nix` and `home.nix` that records which NixOS release the system was first installed on. It controls defaults for stateful data formats and must not be changed after initial setup.

---

## Further Reading

- NixOS Manual
- Nix Flakes - An Introduction
- Home Manager Manual
- Herdr Documentation
- lazy.nvim Plugin Manager
- WezTerm Configuration Reference
- Claude Code Documentation
- Ollama Model Library
- HuggingFace Hub CLI Documentation

---

## Credits and Acknowledgements

Agentic development environment design and NixOS setup adapted from Kun Chen's macOS-to-NixOS walkthrough.

VoxType voice dictation support via the peteonrails/voxtype flake.

---

## Contact

<div align="center">
  <img src="images/thumbnails/ehcastroh_teach_banner_flower.png" alt="ehcastroh" width="90" style="border-radius: 50%;" />

  <sub>ehcastroh</sub>

  <a href="https://github.com/ehcastroh">GitHub</a> · <a href="https://www.linkedin.com/in/ehcastroh/">LinkedIn</a>
</div>
