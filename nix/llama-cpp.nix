# ~/Projects/dotfiles/nix/llama-cpp.nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.llama-cpp.override { cudaSupport = true; })
  ];
}
