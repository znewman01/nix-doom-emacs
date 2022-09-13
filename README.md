| readme        | reference                                | faq                           |
|      ---      |                  ---                     |            ---                |
| this document |  [docs/reference.md](./docs/reference.md)| [docs/faq.md](./docs/faq.md)  |

# nix-doom-emacs

|     | Status |
| --- | --- |
| Build on `master` | [![Build Status on master](https://github.com/nix-community/nix-doom-emacs/workflows/Check%20Build/badge.svg?branch=master&event=push)](https://github.com/nix-community/nix-doom-emacs/actions/workflows/check-build.yml?query=branch%3Amaster) |
| Dependency updater | [![Dependency Updater Status](https://github.com/nix-community/nix-doom-emacs/workflows/Update%20Dependencies/badge.svg?branch=master)](https://github.com/nix-community/nix-doom-emacs/actions/workflows/update-dependencies.yml?query=branch%3Amaster) |
| Matrix Chat | [![Matrix Chat](https://img.shields.io/static/v1?label=chat&message=doom-emacs&color=brightgreen&logo=matrix)](https://matrix.to/#/#doom-emacs:nixos.org) |

Nix expression to install and configure
[doom-emacs](https://github.com/doomemacs/doomemacs).

nix-doom-emacs (also commonly referred to as NDE in chatrooms) is a project with lots of moving pieces and hacks. Users are expected to know their way around using (and especially debugging) Nix and Emacs Lisp in order to use this project.

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
<table><tr>Home-Manager<th></th><th>NixOS</th><th>Standalone</th></tr><tr><th>[Flake + Home-Manager](./docs/reference.md#flake--home-manager)</th><th>[NixOS](./docs/reference.md#nixos)</th><th>[Standalone](./docs/reference.md#standalone)</th></tr></table>

