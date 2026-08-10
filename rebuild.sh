#!/usr/bin/env bash
set -e
cd ~/.dotfiles
sudo nixos-rebuild switch --flake .
sudo chown -R elcasnix:users ~/Projects/dotfiles
