<table><tr><th>faq</th><th>readme</th><th>reference</th></tr><tr><th>this document</th><th>[README.md](/README.md)</th><th>[docs/reference.md](./docs/reference.md)</th></tr></table>

# FAQ
This is more meant as a "Fully Anticipated Questions" than a "Frequently Asked Questions", as they're anticipated as common pitfalls to using NDE.

## I am new to Nix. Is this the only way to use Doom Emacs with Nix/NixOS?

Nope! Doom Emacs is still perfectly usable imperatively. In fact, the very author of Doom Emacs uses NixOS and install Doom Emacs with an ["imperative" setup](https://github.com/hlissner/dotfiles/blob/master/modules/editors/emacs.nix). You could just follow the instructions on the [Doom Emacs GitHub repository](https://github.com/doomemacs/doomemacs) to get a working setup.

## OK, I put your snippets into my NixOS configuration, and I put my Doom Emacs configuration as well. How do I `doom sync`?

To update your Doom Emacs config, you simply rebuild your configuration. For example, in NixOS you can use `nixos-rebuild switch` (or `home-manager switch` if you use Home-Manager standalone). nix-doom-emacs will do everything else for you.

In an imperative environment, Doom updates can break Emacs with no easy way to roll back.
nix-doom-emacs moves the moving parts of your Emacs installation into the Nix build sandbox.

## How do I add a native dependency to a package's build?

You should use the `emacsPackagesOverlay` attribute. Here's an example that installs `magit-delta`, which depends on Git:

```nix
programs.doom-emacs = {
  # ...
  emacsPackagesOverlay = self: super: {
    magit-delta = super.magit-delta.overrideAttrs (esuper: {
      buildInputs = esuper.buildInputs ++ [ pkgs.git ];
    });
  }
};
```

## How do I add a package that's only on GitHub (or any Git frontend)

This requires a few more lines, but it isn't by any means difficult. For an example, this installs `idris2-mode` which isn't on ELPA, but is hosted on GitHub:

```nix
programs.doom-emacs = {
  # ...
  emacsPackagesOverlay = self: super: {
    idris2-mode = self.trivialBuild {
      pname = "idris2-mode";
      ename = "idris2-mode";
      version = "0.0.0";
      buildInputs = [ self.prop-menu ];
      src = pkgs.fetchFromGitHub {
        owner = "idris-community";
        repo = "idris2-mode";
        rev = "4a3f9cdb1a155da59824e39f0ac78ccf72f2ca97";
        sha256 = "sha256-TxsGaG2fBRWWP9aas59kiNnUVD4ZdNlwwaFbM4+n81c=";
      };
    };
  }
};
```

## nix-doom-emacs isn't working if I set DOOMDIR or EMACSDIR

You shouldn't do that. nix-doom-emacs' home-manager module only writes `~/.emacs.d/init.el` in your `$HOME`, which points to the Nix store. Make sure to remove the environment variables from your configuration, then reboot after rebuilding it. If for just the session, you can just `unset` those 2 variables.

## I'm on MacOS and it says "Too many files open"!

Running `ulimit -S -n 2048` will fix it for the duration of your shell session.
For a more permanent solution, NixOS has [`security.pam.loginLimits`](https://search.nixos.org/options?channel=22.05&from=0&size=50&sort=relevance&type=packages&query=security.pam.loginLimits)
