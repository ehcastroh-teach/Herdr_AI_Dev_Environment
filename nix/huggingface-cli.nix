# ~/Projects/dotfiles/nix/huggingface-cli.nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.python312Packages.huggingface-hub
  ];
}
