# ~/Projects/dotfiles/nix/huggingface-cli.nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.huggingface-cli
  ];
}
