<table><tr><th>faq</th><th>readme</th><th>reference</th></tr><tr><th>[docs/faq.md](./faq.md)</th><th>[README.md](/README.md)</th><th>this document</th></tr></table>

# nix-doom-emacs reference

If you encounter any issues while using nix-doom-emacs, you can find some of us in the [Matrix room](https://matrix.to/#/#doom-emacs:nixos.org). Only bugs should be filed in our [issue tracker](https://github.com/nix-community/nix-doom-emacs/issues).

nix-doom-emacs uses [`nix-straight.el`](https://github.com/nix-community/nix-straight.el) under the hood to install dependencies. It's a low level wrapper to integrate Nix with [`straight.el`](https://github.com/radian-software/straight.el). It is maintained by the same people as this project.

Currently, `nix-straight.el` only extracts package names and uses [`emacs-overlay`](https://github.com/nix-community/emacs-overlay) to obtain the package sources. This works most of the time but occasionally results in very obscure issues.

# Getting Started

To get started, we suggest these methods. They are ordered from most suggested to least suggested.
In all of these methods, you'll need your Doom Emacs configuration. It should contain the following three files: 
`config.el`, `init.el` and `packages.el`. If you don't already have an existing `doom-emacs` configuration, you can use the contents of `test/doom.d` as a template.

## Home-Manager

### With Flakes

`File: flake.nix`
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"
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
              doomPrivateDir = ./doom.d; # Directory containing your config.el, init.el
                                         # and packages.el files
            };
          };
        }
      ];
    };
  };
}
```

### Without Flakes

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
                doomPrivateDir = ./doom.d;
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

# Setup

## Emacs daemon
If you use the Home-Manager module, you can enable it via `services.emacs.enable = true;`. The Home-Manager module will do the rest for you.

If you're not, and you're using a standalone method (NixOS only without home-manager/nix-darwin) instead, you'll need:

```nix
services.emacs = {
  enable = true;
  package = inputs.doom-emacs.packages.${system}.doom-emacs.override {
    doomPrivateDir = ./doom.d;
  };
};
```

You can now run `emacsclient -c` to connect to the daemon.

## Custom Emacs derivations (i.e., pgtk, nativeComp)

You can use the `emacsPackage` attribute after applying `emacs-overlay` to your Nixpkgs:

```nix
programs.doom-emacs =   {
  enable = true;
  doomPrivateDir = ./doom.d;
  emacsPackage = pkgs.emacsPgtkNativeComp;
}
```

For Non-HM:

```nix
let
  # ...
  doom-emacs = nix-doom-emacs.packages.${system}.default.override {
    doomPrivateDir = ./doom.d;
    emacsPackage = pkgs.emacsPgtkNativeComp;
  };
in {
  # ...
}
```

And for Non-Flake:
```nix
let
  # ...
  nix-doom-emacs = pkgs.callPackage (import repo) {
    doomPrivateDir = ./doom.d;
    emacsPackage = pkgs.emacsPgtkNativeComp
  };
in {
  # ...
}
```

## trivialBuild and co

Though beyond the scope of this document, [`trivialBuild`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/trivial.nix) is a Nixpkgs function to trivially build Emacs packages, if you're confused about it's usage here. You can use it to build e.g. local packages or packages hosted on Git repositories. It is not a nix-doom-emacs tool. It's also in a family of functions in Nixpkgs which are made to build Emacs packages. Such as:

[`generic`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/generic.nix): This is the "base" function which all the other build functions are derived from.

[`elpaBuild`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/elpa.nix), and [`melpaBuild`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/elpa.nix): Those are self-explanatory. To find examples of how they're used, you'll unfortunately have to [search Nixpkgs](https://github.com/NixOS/nixpkgs/search) for them. Luckily, the way they're used in Nixpkgs is very simple.
