# FAQ
This is more meant as a "Fully Anticipated Questions" than a "Frequently Asked Questions", as they're anticipated as common pitfalls to using NDE.

## I am new to Nix. Is this the only way to use Doom Emacs with Nix/NixOS?

Nope! Doom Emacs is still perfectly usable imperatively. In fact, the very author of Doom Emacs uses NixOS and install Doom Emacs with an ["imperative" setup](https://github.com/hlissner/dotfiles/blob/master/modules/editors/emacs.nix). You could just follow the instructions on the [Doom Emacs GitHub repository](https://github.com/doomemacs/doomemacs) to get a working setup.

## OK, I put your snippets into my NixOS configuration, and I put my Doom Emacs configuration as well. How do I `doom sync`?

To update your Doom Emacs config, you simply rebuild your configuration. For example, in NixOS you can use `nixos-rebuild switch` (or `home-manager switch` if you use Home-Manager standalone). Nix-Doom-Emacs will do everything else for you.

## How do I install my favourite package?

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

### But what if my package is from a Git source, and isn't on ELPA?

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

### Help! My favourite package doesn't work after adding it in!

This usually happens when the package depends on either some ELPA package or a normal package that you need to add into the `buildInputs` to make it work. 
Let's take the above `idris2-mode` package, and I'll remove the `buildInputs` line:

**WARNING**: THIS IS ERRONEOUS CODE FOR DEMONSTRATION. DO NOT USE THIS SNIPPET, THE ABOVE ONE IS THE FUNCTIONING VERSION.
```nix
programs.doom-emacs = {
  # ...
  emacsPackagesOverlay = self: super: {
    idris2-mode = self.trivialBuild {
      pname = "idris2-mode";
      ename = "idris2-mode";
      version = "0.0.0";
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

This will error with (this is a part of the build log):

```
In toplevel form:
idris2-hole-list.el:27:2: Error: Cannot open load file: No such file or directory, prop-menu

In toplevel form:
idris2-info.el:29:2: Error: Cannot open load file: No such file or directory, prop-menu

In idris2-ipkg-pkgs-flags-for-current-buffer:
idris2-ipkg-mode.el:372:2: Warning: docstring wider than 80 characters

In toplevel form:
idris2-mode.el:20:2: Error: Cannot open load file: No such file or directory, prop-menu

In idris2-prover-end:
idris2-prover.el:378:2: Warning: docstring wider than 80 characters

In toplevel form:
idris2-repl.el:29:2: Error: Cannot open load file: No such file or directory, prop-menu
```

The way to fix it is by just adding the dependency it's complaining about.

Though, not all packages will complain very clearly about missing dependencies or really any issue. The best way to know how to get around this is to know how to debug Nix packages and derivations. Tools like `nix build`, `nix repl`, and `nix log` are your friend. Especially if you want to debug another person's configuration, or your own Nix-Doom-Emacs configuration without needing to `nixos-rebuild` it, then `nix build` is very useful.

For an example, if a person is using Home-Manager+NixOS, then you can build their configuration via `nix build $CONFIG_PATH_HERE#nixosConfigurations.nixos.config.home-manager.users.$USER_HERE.programs.doom-emacs.package`. You need to replace `$CONFIG_PATH_HERE` with the path (like `.` if it's in the current directory), and `$USER_HERE` with the user. This could fail, and if it does, it'll tell you to use the `nix log` command to look at the full log. This will be important.

For the `nix repl` command, it could be very useful for debugging as well. To know how to use it, I suggest [nix pills](https://nixos.org/guides/nix-pills/index.html), and to look at [the nix manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-repl.html)

## How do I enable the service?

There aren't many complications about this. If you use the Home-Manager module, it's simply `services.emacs.enable = true;`. The Home-Manager module will do the rest for you.

If you're not, and you're using a standalone method (NixOS only without home-manager/nix-darwin) instead, you'll need:

```nix
services.emacs = {
  enable = true;
  package = inputs.doom-emacs.packages.${system}.doom-emacs.override {
    doomPrivateDir = ./doom;
  };
};
```

You can now run `emacsclient -c` to connect to the daemon.

## What is `trivialBuild`?

Though beyond the scope of this document, [`trivialBuild`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/trivial.nix) is a Nixpkgs function to trivially build Emacs packages. You can use it to build e.g. local packages or packages hosted on Git repositories. It is not a Nix-Doom-Emacs tool. It's also in a family of functions in Nixpkgs which are made to build Emacs packages. Such as:

[`generic`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/generic.nix): This is the "base" function which all the other build functions are derived from.

[`elpaBuild`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/elpa.nix), and [`melpaBuild`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/emacs/elpa.nix): Those are self-explanatory. To find examples of how they're used, you'll unfortunately have to [search Nixpkgs](https://github.com/NixOS/nixpkgs/search) for them. Luckily, the way they're used in Nixpkgs is very simple.

For what it's worth, this will not be the last time you muddle around in the Nixpkgs code to understand how to use something. The NixOS project is known to have very bad documentation, and unfortunately the code may be your only way to understand some things.

## Help! Nix-Doom-Emacs isn't working if I set DOOMDIR or EMACSDIR

You shouldn't do that. The only thing that Nix-Doom-Emacs writes in your $HOME is `~/.emacs.d/init.el`, which points to the Nix store. Make sure to remove them from your configuration, then reboot after rebuilding it. If for just the session, you can just `unset` those 2 variables.

## Help! on MacOS, it says "Too many files open"!

Running `ulimit -S -n 2048` will fix it for the duration of your shell session.

## How do I use emacs-overlay's emacs with Nix-Doom-Emacs?

This is very simple. you just use the `emacsPackage` attribute after applying `emacs-overlay` to your Nixpkgs. something like:

```nix
programs.doom-emacs =   {
  enable = true;
  doomPrivateDir = ./doom;
  emacsPackage = pkgs.emacsPgtkNativeComp; # I used the native comp pgtk as an example
}
```
