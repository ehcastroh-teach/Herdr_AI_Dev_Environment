{ config, pkgs, pkgs-unstable, voxtype-pkgs, ... }:

{
  home.username = "elcasnix";
  home.homeDirectory = "/home/elcasnix";
  home.stateVersion = "25.11";

  home.packages = [
    pkgs-unstable.neovim
    pkgs-unstable.herdr
    pkgs-unstable.opencode
    pkgs.nodejs_20
    voxtype-pkgs.vulkan  # Vulcan works NVIDIA w/out CUDA
    voxtype-pkgs.osd-gtk4
    ];

  assertions = [{
    assertion = pkgs.lib.versionAtLeast pkgs-unstable.neovim.version "0.12.3";
    message = "neovim ${pkgs-unstable.neovim.version} is below the required 0.12.3";
  }];

  # ---- Symlinks: repo is the source of truth --------------------------------
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/nvim"; 
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/claude/settings.json";

  # ---- Agent memory: one file, symlinked to every harness --------------------
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/AGENTS.md";

  # ---- Additional Functionality ---------------------------------------------
  home.file.".config/voxtype".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/voxtype";

  # ---- Shell ----------------------------------------------------------------
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''bindkey '^f' autosuggest-accept'';
    shellAliases = {
      v = "nvim"; g = "git"; gs = "git status"; ga = "git add";
      gc = "git commit"; gp = "git push"; gd = "git diff";
      rebuild = "~/.dotfiles/rebuild.sh";
    };
  };
  
  # ---- git ----
  programs.git = {
    enable = true;
    settings.user = {
	name = "eliascasher";
    	email = "ehcastroh@berkeley.edu";
  	};
    extraConfig.url."git@github.com:".insteadOf = "https://github.com/";
  };

  # ---- starship ----
  programs.starship = {
    enable = true;
    settings = { 
	add_newline = false;
	format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
	};
  };

  # ---- GNOME Keybindings ----
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Ctrl><Alt>t";
      command = "wezterm";
      name = "Open WezTerm";
    };
  };
  
  # ---- VoxType ----
  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype dictation daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${voxtype-pkgs.vulkan}/bin/voxtype daemon";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # ---- NeoVIM ----
  home.sessionVariables = { EDITOR = "nvim"; };
}
