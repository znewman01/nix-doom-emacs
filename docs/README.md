# Documentation for Nix-Doom-Emacs

Nix-Doom-Emacs (also commonly referred to as NDE in chatrooms) is a project with a lot of moving pieces and hacks; it's a project that is itself a fork of another project that has these moving pieces. Thus, it's not out of the blue to expect it to be a tiny bit more buggy for most people than other software. If you encounter any issues that make it not usable to you (or if you need support), please talk to us first in the [Matrix room](https://matrix.to/#/#doom-emacs:nixos.org) and if it's indeed a bug of Nix-Doom-Emacs, file it in the [issue tracker](https://github.com/nix-community/nix-doom-emacs/issues). If you find this documentation unclear or incomplete, please let us know as well.

Here's the [FAQ](./faq.md)

Nix-Doom-Emacs uses [nix-straight.el](https://github.com/nix-community/nix-straight.el) under the hood to install dependencies. It's a low level wrapper to add Nix integration over straight.el, the declarative package manager used by Doom Emacs. 

If you're not aware yet, then:

#### **WARNING**: HERE BE DRAGONS! THIS IS A FRAGILE PROJECT

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
    lib,
    home-manager,
    nix-doom-emacs,
    ...
  }:
    let
      system      = "x86_64-linux";
      specialArgs = { inherit inputs; };
    in {
    nixosConfigurations.exampleHost = lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.exampleUser.imports = [ ./home.nix ];
        }
      ];
    };
  };
}

```

`File: home.nix`
```nix
{ config, pkgs, inputs, ... }: {
  imports = [ inputs.nix-doom-emacs.hmModule ];

  # ...
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d; # Directory containing your config.el, init.el
                               # and packages.el files
  };
  # ...
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


## Standalone

Using Nix-Doom-Emacs standalone isn't recommended, especially if you're a beginner.

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
    lib,
    nix-doom-emacs,
    ...
  }:
    let
      system      = "x86_64-linux";
      specialArgs = { inherit inputs; };
    in {
    nixosConfigurations.exampleHost = lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ./default.nix
        # ...
      ];
    };
  };
}
```

`File: default.nix`
```nix
{ config, nixpkgs, lib, inputs }: {
  # ...
  environment.systemPackages = 
    let
      doom-emacs = inputs.nix-doom-emacs.packages.${system}.default.override {
        doomPrivateDir = ./doom;
      };
    in [
      doom-emacs
    ];
  # ...
}
```
