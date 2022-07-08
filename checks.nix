{ system }:
{ self, nixpkgs, emacs-overlay, ... }@inputs:

let
  pkgs = import nixpkgs {
    inherit system;
    # we are not using emacs-overlay's flake.nix here,
    # to avoid unnecessary inputs to be added to flake.lock;
    # this means we need to import the overlay in a hack-ish way
    overlays = [ (import emacs-overlay) ];
  };
in
{
  init-example-el = self.outputs.package.${system} {
    doomPrivateDir = ./test/doom.d;
    dependencyOverrides = inputs;
  };
  init-example-el-emacsGit = self.outputs.package.${system} {
    doomPrivateDir = ./test/doom.d;
    dependencyOverrides = inputs;
    emacsPackages = with pkgs; emacsPackagesFor emacsGit;
  };
}
