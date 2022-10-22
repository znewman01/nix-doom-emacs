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
  # we are cloning HM here for the same reason as above, to avoid
  # an extra additional input to be added to flake
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/tarball/c485669ca529e01c1505429fa9017c9a93f15559";
    sha256 = "1zdclkqg1zg06x986q4s03h574djbk8vyrhyqar9yzk61218vmij";
  };
in
{
  home-manager-module = (import "${home-manager}/modules" {
    inherit pkgs;
    configuration = {
      imports = [ self.outputs.hmModule ];
      home = {
        username = "nix-doom-emacs";
        homeDirectory = "/tmp";
        stateVersion = "22.11";
      };
      programs.doom-emacs = {
        enable = true;
        doomPrivateDir = ./test/doom.d;
      };
    };
  }).activationPackage;
  init-example-el = self.outputs.package.${system} {
    doomPrivateDir = ./test/doom.d;
    dependencyOverrides = inputs;
  };
  init-example-el-emacsGit = self.outputs.package.${system} {
    doomPrivateDir = ./test/doom.d;
    dependencyOverrides = inputs;
    emacsPackages = with pkgs; emacsPackagesFor emacsGit;
  };
  init-example-el-splitdir = self.outputs.package.${system} {
    dependencyOverrides = inputs;
    doomPrivateDir = pkgs.linkFarm "my-doom-packages" [
         { name = "config.el"; path = ./test/doom.d/config.el; }
         { name = "init.el"; path = ./test/doom.d/init.el; }
         # Should *not* fail because we're building our straight environment
         # using the doomPackageDir, not the doomPrivateDir.
         {
           name = "packages.el";
           path = pkgs.writeText "packages.el" "(package! not-a-valid-package)";
         }
       ];
    doomPackageDir = pkgs.linkFarm "my-doom-packages" [
         # straight needs a (possibly empty) `config.el` file to build
         { name = "config.el"; path = pkgs.emptyFile; }
         { name = "init.el"; path = ./test/doom.d/init.el; }
         {
           name = "packages.el";
           path = pkgs.writeText "packages.el" "(package! inheritenv)";
         }
       ];
  };
}
