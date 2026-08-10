# =============================================================================
# NixOS System Configuration — elcasnix @ nixos
# =============================================================================
# Edit:    sudo vim /etc/nixos/configuration.nix   (or via your dotfiles repo)
# Apply:   sudo nixos-rebuild switch               (or ./rebuild.sh with flakes)
# Help:    nixos-help  ·  man configuration.nix  ·  https://search.nixos.org/options
#
# Layout of this file:
#   1. Imports                    6. Desktop (X11 / GNOME)
#   2. Boot                       7. Services (printing, audio)
#   3. Networking                 8. Users & Shell
#   4. Swap                       9. Nix & nixpkgs settings
#   5. Locale & Time             10. Graphics (NVIDIA)
#                                11. System Packages
#                                12. Program Modules (tmux, firefox)
#                                13. Fonts
#                                14. State Version (do not touch)
# =============================================================================

{ config, pkgs, ... }:

{
  # ===========================================================================
  # 1. IMPORTS
  # ===========================================================================
  # hardware-configuration.nix is machine-specific (disk UUIDs, kernel modules,
  # filesystems). It is auto-generated; regenerate with `nixos-generate-config`
  # only if hardware changes. Never share it between machines.
  imports = [
    ./hardware-configuration.nix
    ./nix/llama-cpp.nix
    ./nix/ollama.nix
    ./nix/huggingface-cli.nix
  ];

  # ===========================================================================
  # 2. BOOT
  # ===========================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep only the last 5 generations in the boot menu. Older generations are
  # still your rollback safety net until garbage-collected, but this keeps the
  # boot screen tidy.
  boot.loader.systemd-boot.configurationLimit = 5;

  # ===========================================================================
  # 3. NETWORKING
  # ===========================================================================
  networking.hostName = "nixos"; # Must match the flake's nixosConfigurations key

  # NetworkManager handles both wired and WiFi (GNOME integrates with it).
  networking.networkmanager.enable = true;

  # wpa_supplicant alternative — do NOT enable alongside NetworkManager:
  # networking.wireless.enable = true;

  # Proxy, if ever needed:
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Firewall is ON by default on NixOS; stated here explicitly for clarity.
  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # ===========================================================================
  # 4. SWAP
  # ===========================================================================
  # 16 GiB swapfile. Size is in MiB.
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];

  # ===========================================================================
  # 5. LOCALE & TIME
  # ===========================================================================
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # ===========================================================================
  # 6. DESKTOP — X11 + GNOME
  # ===========================================================================
  services.xserver.enable = true;

  # GNOME with the GDM login screen.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Keyboard layout (X11).
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Touchpad support is enabled by default in most desktop managers:
  # services.xserver.libinput.enable = true;

  # ===========================================================================
  # 7. SERVICES
  # ===========================================================================
  # ---- Printing (CUPS) ----
  services.printing.enable = true;

  # Network printer discovery (mDNS/Avahi).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ---- Audio: PipeWire (replaces PulseAudio) ----
  services.pulseaudio.enable = false; # PipeWire provides the Pulse API instead
  security.rtkit.enable = true;       # realtime scheduling for low-latency audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;             # uncomment for JACK applications
  };

  # ---- SSH (off; uncomment to enable remote access) ----
  # services.openssh.enable = true;
  
  # ---- Voice ----
  hardware.uinput.enable = true;  # uinput device for synthetic keystrokes

  # ---- Ollama ----
  services.ollama.acceleration = "cuda";

  # ===========================================================================
  # 8. USERS & SHELL
  # ===========================================================================
  # Set the initial password with `passwd` after first build.
  users.users.elcasnix = {
    isNormalUser = true;
    description = "Elias";
    extraGroups = [
      "networkmanager" # manage network connections without sudo
      "wheel"          # sudo access
      "input"          # synthetic keystrokes
      "uinput"         # voice to text
    ];

    # [ADDED] Zsh as login shell — required for the Home Manager zsh setup
    # (autosuggestions, syntax highlighting, aliases) in the agentic-env guide.
    shell = pkgs.zsh;

    # User-only packages (prefer Home Manager's home.packages once adopted).
    packages = with pkgs; [
    ];
  };

  # [ADDED] Required whenever any user's shell is zsh; without it, NixOS won't
  # register zsh in /etc/shells and login breaks.
  programs.zsh.enable = true;

  # ===========================================================================
  # 9. NIX & NIXPKGS SETTINGS
  # ===========================================================================
  # Modern nix CLI + flakes, system-wide. Required for `nixos-rebuild --flake`,
  # `nix develop`, and the dotfiles workflow.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow proprietary packages (google-chrome, vscode, obsidian, nvidia, etc.).
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  # [ADDED] Weekly garbage collection of generations older than 30 days.
  # Keeps /nix/store from growing unbounded while preserving a month of
  # rollback targets. Remove this block if you prefer manual GC.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ===========================================================================
  # 10. GRAPHICS — NVIDIA
  # ===========================================================================
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;                # open kernel module; REQUIRES driver >= 560
    modesetting.enable = true;
  };

  # Renamed from hardware.opengl in newer NixOS releases.
  hardware.graphics.enable = true;

  # ===========================================================================
  # 11. SYSTEM PACKAGES
  # ===========================================================================
  # Strictly standalone applications and utilities.
  # Do NOT put configuration blocks or modules like `programs.tmux` in here —
  # those belong in section 12.
  environment.systemPackages = with pkgs; [
    # ---- Web ----
    google-chrome

    # ---- Programming ----
    vscode
    rustup      # Rust toolchain manager
    git
    gh          # GitHub CLI
    vim-full    # bootstrap/fallback editor
    neovim      # primary editor

    # ---- Networking tools ----
    curl        # transfer data across network servers
    wget        # download files from web

    # ---- AI / DS ----
    python3
    claude-code # Claude Code CLI (agentic coding)
    obsidian    # markdown knowledge base / note-taking
    wezterm     # GPU-accelerated terminal emulator (config: ~/.config/wezterm)
    # qmd.packages.${pkgs.system}.default  # local markdown search

    # ---- Security, navigation, observability ----
    pciutils    # lspci — inspect PCI hardware
    htop
    btop
    glances
    diceware    # generate passphrases

    # ---- Nix tooling ----
    nvd         # diff between system generations (great after rebuilds)
    nil         # Nix language server (LSP for editing .nix files)
    wl-clipboard # Wayland clipboard — required for Neovim `clipboard=unnamedplus`
    yt-dlp      # download video/subtitles (.vtt)
    dotool      # typing backend for GNOME wayland
    libnotify   # desktop notifications

    # ---- Development environments ----
    direnv      # per-directory environments via .envrc
    nix-direnv  # fast, cached `use flake` support for direnv
    devbox

    # ---- [ADDED] Neovim picker/grep backends ----
    # snacks.nvim's file & grep pickers (from the agentic-env guide) shell out
    # to these. Without them, <leader>f and <leader>s won't work.
    ripgrep     # grep engine
    fd          # file finder
  ];

  # ===========================================================================
  # 12. PROGRAM MODULES
  # ===========================================================================
  # Top-level NixOS module options: these configure an entire software
  # environment (config files, plugins, wrappers), not just a raw binary.

  # ---- Firefox ----
  programs.firefox.enable = false;

  # ---- tmux ----
  programs.tmux = {
    enable = true;
    clock24 = true;
    shortcut = "a"; # changes default prefix to Ctrl-a
    extraConfig = ''
      # Custom tmux.conf settings here
      set -g mouse on
    '';
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.yank
    ];
  };

  # ---- Some programs need SUID wrappers or session integration ----
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # ===========================================================================
  # 13. FONTS
  # ===========================================================================
  # [ADDED] Hack Nerd Font — your wezterm.lua sets
  # `config.font = wezterm.font("Hack Nerd Font")`; without the font installed
  # system-wide, WezTerm silently falls back to a default.
  # (Pre-25.05 releases use: (nerdfonts.override { fonts = [ "Hack" ]; }))
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  # ===========================================================================
  # 14. STATE VERSION — DO NOT CHANGE
  # ===========================================================================
  # Determines the NixOS release whose defaults for STATEFUL data (file
  # locations, database formats) this system uses. It records the release you
  # first installed and must stay at that value even as you upgrade nixpkgs.
  # Read the docs before ever changing it (man configuration.nix).
  system.stateVersion = "25.11"; # Did you read the comment?
}
