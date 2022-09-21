| readme | [reference](./docs/reference.md)| [faq](./docs/faq.md)  |

# nix-doom-emacs

|     | Status |
| --- | --- |
| Build on `master` | [![Build Status on master](https://github.com/nix-community/nix-doom-emacs/workflows/Check%20Build/badge.svg?branch=master&event=push)](https://github.com/nix-community/nix-doom-emacs/actions/workflows/check-build.yml?query=branch%3Amaster) |
| Dependency updater | [![Dependency Updater Status](https://github.com/nix-community/nix-doom-emacs/workflows/Update%20Dependencies/badge.svg?branch=master)](https://github.com/nix-community/nix-doom-emacs/actions/workflows/update-dependencies.yml?query=branch%3Amaster) |
| Matrix Chat | [![Matrix Chat](https://img.shields.io/static/v1?label=chat&message=doom-emacs&color=brightgreen&logo=matrix)](https://matrix.to/#/#doom-emacs:nixos.org) |

nix-doom-emacs (abbreviated as NDE) provides a customisable Nix derivation for [Doom Emacs](https://github.com/doomemacs/doomemacs)
The project has lots of moving pieces and hacks. Users are expected to know their way around using (and especially debugging) Nix and Emacs Lisp in order to use this project.

The expression builds a `doom-emacs` distribution with dependencies
pre-installed based on an existing `~/.doom.d` directory.

It is not a fully fledged experience as some dependencies are not installed and
some may not be fully compatible as the version available in NixOS or
[emacs-overlay](https://github.com/nix-community/emacs-overlay) may not be
compatible with the `doom-emacs` requirements.

# Quick Start

If you want to get a taste of nix-doom-emacs, you can run ``nix run github:nix-community/nix-doom-emacs``
Which will run nix-doom-emacs with an example configuration. 

Pick which setup you're using here (if you're not using NixOS or Home-Manager, then you should use standalone):

| Home-Manager | NixOS | Standalone |
|      ---     |  ---  |    ---     |
| [Flake + Home-Manager](./docs/reference.md#home-manager) | [NixOS](./docs/reference.md#nixos) | [Standalone](./docs/reference.md#standalone) |


# Hacking

This project is licensend under MIT. Only bugs should be filed in our [issue tracker](https://github.com/nix-community/nix-doom-emacs/issues).
The `PR wanted` label is for issues that we'd appreciate PRs for the most.
Contributions are welcome.
