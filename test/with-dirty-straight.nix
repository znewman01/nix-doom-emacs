{ pkgs ? import <nixpkgs> { } }:

pkgs.callPackage (import ../default.nix) {
  doomPrivateDir = ./doom.d;
  bundledPackages = true;
  dependencyOverrides.nix-straight = ../../nix-straight.el;
}
