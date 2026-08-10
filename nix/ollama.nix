# ~/Projects/Local_LLM/nix/ollama.nix
# Import this from your system flake or configuration.nix:
# imports = [ ./nix/ollama.nix ];

{ pkgs, ... }: {
  services.ollama = {
    enable = false;
    acceleration = "cuda";
    package = pkgs.ollama.override { acceleration = "cuda"; };
    # Optional: pre-pull models on activation
    loadModels = ["gemma3:4b"];
  };

  nixpkgs.config = {
    allowUnfree  = true;
  };
}
