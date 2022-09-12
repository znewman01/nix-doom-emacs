# Documentation for nix-doom-emacs

nix-doom-emacs (also commonly referred to as NDE in chatrooms) is a project with lots of moving pieces and hacks. Users are expected to know their way around using (and especially debugging) Nix and Emacs Lisp before using this project.

If you encounter any issues that make it unusable to you (or if you need support), please talk to us first in the [Matrix room](https://matrix.to/#/#doom-emacs:nixos.org) and if it's indeed a bug of nix-doom-emacs, file it in the [issue tracker](https://github.com/nix-community/nix-doom-emacs/issues).

If you find this documentation unclear or incomplete, please let us know as well.

Here's the [FAQ](./faq.md)

nix-doom-emacs uses [`nix-straight.el`](https://github.com/nix-community/nix-straight.el) under the hood to install dependencies. It's a low level wrapper to add Nix integration over [`straight.el`](https://github.com/radian-software/straight.el), the declarative package manager used by Doom Emacs. 

Before using nix-doom-emacs, make sure to read [`nix-straight.el`'s README'](https://github.com/nix-community/nix-straight.el), and that you understand the consequences.

# Getting Started

To get started, we suggest these methods. They are ordered from most suggested to least suggested.
In all of these methods, you'll need your Doom Emacs configuration. It should contain the following three files: 
`config.el`, `init.el` and `packages.el`. If you don't already have an existing `doom-emacs` configuration, you can use the contents of `test/doom.d` as a template.

The Doom configuration will be referred to as `./doom.d` in these snippets. You can name it whatever you like.

## Flake + Home-Manager

`File: flake.nix`
```nix
{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-doom-emacs,
    ...
  }: {
    nixosConfigurations.exampleHost = nixpkgs.lib.nixosSystem {
      system  = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.users.exampleUser = { ... }: {
            imports = [ nix-doom-emacs.hmModule ];
            programs.doom-emacs = {
              enable = true;
              doomPrivateDir = ./doom; # Directory containing your config.el, init.el
                                       # and packages.el files
            };
          };
        }
      ];
    };
  };
}
```

## Non-Flake Home-Manager

```nix
{ pkgs, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
  }) {
    doomPrivateDir = ./doom.d;  # Directory containing your config.el, init.el
                                # and packages.el files
  };
in {
  home.packages = [ doom-emacs ];
}
```


## NixOS

`File: flake.nix`
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
  };
  
  outputs = {
    self,
    nixpkgs,
    nix-doom-emacs,
    ...
  }: {
    nixosConfigurations.exampleHost = nixpkgs.lib.nixosSystem {
      system  = "x86_64-linux";
      modules = [
        { 
          environment.systemPackages = 
            let
              doom-emacs = inputs.nix-doom-emacs.packages.${system}.defaut.override {
                doomPrivateDir = ./doom;
              };
            in [
              doom-emacs
            ];
        }
        # ...
      ];
    };
  };
}
```

For what it's worth, you can see all overridable parameters of nix-doom-emacs in [default.nix](../default.nix).

## Standalone

### Flake

```nix
{
  description = "nix-doom-emacs shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
  };

  outputs = { self, nixpkgs, nix-doom-emacs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    doom-emacs = nix-doom-emacs.packages.${system}.default.override {
      doomPrivateDir = ./doom.d;
    };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ doom-emacs ];
    };
  };
}
```

### Non-Flake
```nix
{ pkgs ? import <nixpkgs> { } }:

let
  repo = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-doom-emacs";
    rev = "<commit>";
    sha256 = "<hash>";
  };
  nix-doom-emacs = pkgs.callPackage (import repo) {
    doomPrivateDir = ./doom.d;
  };
in
pkgs.mkShell {
  buildInputs = [ nix-doom-emacs ];
}
```
