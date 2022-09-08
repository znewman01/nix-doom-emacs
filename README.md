# nix-doom-emacs

|     | Status |
| --- | --- |
| Build on `master` | [![Build Status on master](https://github.com/nix-community/nix-doom-emacs/workflows/Check%20Build/badge.svg?branch=master&event=push)](https://github.com/nix-community/nix-doom-emacs/actions/workflows/check-build.yml?query=branch%3Amaster) |
| Dependency updater | [![Dependency Updater Status](https://github.com/nix-community/nix-doom-emacs/workflows/Update%20Dependencies/badge.svg?branch=master)](https://github.com/nix-community/nix-doom-emacs/actions/workflows/update-dependencies.yml?query=branch%3Amaster) |
| Matrix Chat | [![Matrix Chat](https://img.shields.io/static/v1?label=chat&message=doom-emacs&color=brightgreen&logo=matrix)](https://matrix.to/#/#doom-emacs:nixos.org) |

Nix expression to install and configure
[doom-emacs](https://github.com/doomemacs/doomemacs).

The expression builds a `doom-emacs` distribution with dependencies
pre-installed based on an existing `~/.doom.d` directory.

It is not a fully fledged experience as some dependencies are not installed and
some may not be fully compatible as the version available in NixOS or
[emacs-overlay](https://github.com/nix-community/emacs-overlay) may not be
compatible with the `doom-emacs` requirements.

# Documentation
To know how to use Nix-Doom-Emacs, and to fix other issues, check the [documentation](./docs)
