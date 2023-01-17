| index |     |     |
| --- | --- | --- |
|[readme](../README.md)|[reference](./reference.md)|**faq**|

# Frequently Asked Questions

## I am new to Nix. Is this the only way to use Doom Emacs with Nix/NixOS?

Nope! Doom Emacs is still perfectly usable imperatively. In fact, the very author of Doom Emacs uses NixOS and install Doom Emacs with an ["imperative" setup](https://github.com/hlissner/dotfiles/blob/master/modules/editors/emacs.nix). You can follow the instructions on the [Doom Emacs GitHub repository](https://github.com/doomemacs/doomemacs) to get a working setup.


## How do I add a non-(M)ELPA dependency to a package's build?

You'd usually need to do this when a (M)ELPA pakage needs some package to exist on your system, like `git` for example.

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

If you try to add a package that isn't from (M)ELPA, you'd get this error: `Package not available`. This is because `nix-straight.el` assumes that packages are on emacs-overlay's packages, which only include (M)ELPA.
This question assumes the package uses GitHub, so it uses the `fetchFromGitHub` function. To see which function you'd need to use, you should look at [the Nixpkgs manual's fetchers section](https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-fetchers)
For an example, this installs `idris2-mode` which isn't on (M)ELPA, but is hosted on GitHub:

```nix
programs.doom-emacs = {
  # ...
  emacsPackagesOverlay = self: super: {
    idris2-mode = self.trivialBuild {
      pname = "idris2-mode";
      ename = "idris2-mode";
      version = "unstable-2022-09-21";
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

You shouldn't do that. nix-doom-emacs' home-manager module writes `~/.emacs.d` in your `$HOME`. Make sure to remove the environment variables from your configuration, then reboot after rebuilding it. If for just the session, you can just `unset` those 2 variables.

## It errors with "Too many files open"!

Running `ulimit -S -n 2048` will fix it for the duration of your shell session.
