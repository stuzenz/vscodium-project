
# How to add the flake in this repo to your NixOS configuration


This was kind of tricky - hence these instructions. 

The ability to build this is all thanks to this project
https://github.com/nix-community/nix-vscode-extensions


## Objective

Have access to all vs code extensions. 

To meet this goal I have used the above project. 
Integrating a local flake into your NixOS configuration is not that straightforward - so I have copied snippets of my configuration files here to show the changes made.

The key changes are:

**Changes for your NixOS `flake.nix` file**

1. Ensure that `codium-flake` is properly included in your `inputs`
2. Add `specialArgs = { inherit codium-flake; };` to your `nixosConfigurations.T14` definition. This passes the `codium-flake` to your configuration modules

**Changes for your `configuration.nix` file**
Now, in your `./system/configuration.nix`, you should be able to access `codium-flake`. Make sure your `configuration.nix` is set up to accept and use this argument:
1. Add codium-flake int your scope of the file
2. Add the following into your pkgs
```
    systemPackages = with pkgs; [

      codium-flake.packages.${system}.default
```


*note the changes are highlighted with comments # add this or # add this line*

```nix
# flake.nix
{
  description = "T14 system configuration with Nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv.url = "github:cachix/devenv/latest";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    hypr-contrib.url = "github:hyprwm/contrib";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    codium-flake.url = "path:/home/stuart/.dotfiles/system/codium";  # add this line
  };

  outputs = { self, nixpkgs, home-manager, devenv, hyprpicker, hypr-contrib, disko, codium-flake, ... }:  # add this
    let
      system = "x86_64-linux";

      overlay = final: prev: {
        bazel-build-jaxlib-0_4_28-deps = prev.bazel-build-jaxlib-0_4_28-deps.overrideAttrs (oldAttrs: {
          outputHash = "sha256-R5Bm+0GYN1zJ1aEUBW76907MxYKAIawHHJoIb1RdsKE=";
        });
      };

      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [ overlay ];
      };

      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        T14 = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit codium-flake; };  # Add this line
          modules = [
            { _module.args.devenv = devenv.packages.${system}.devenv; }
            ./system/configuration.nix
            disko.nixosModules.disko
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay ];
            })
          ];
        };
      };

    hmConfig = {
```

In the configuration.nix file these changes were required

```nix
# configuration.nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, codium-flake, ... }:let       # added here
  flake-compat = builtins.fetchTarball {
    url =  "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  sha256 = "1prd9b1xx8c0sfwnyzkspplh30m613j42l1k789s521f4kv4c2z2";
  };
  
  environment = {
    shells = with pkgs; [ zsh ];          # Default shell
    variables = {                         # System variables
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [

      codium-flake.packages.${system}.default  # added here
```

The actual flake.nix for codium that we added in is here
```bash
➜  .dotfiles git:(main) cd system/codium/
➜  codium git:(main) ls
flake.nix
➜  codium git:(main) pwd
/home/stuart/.dotfiles/system/codium
```

After making these changes:

1. Run `nix flake update` in your dotfiles directory to update the lock file.
2. Try rebuilding your system

```
nix flake update
sudo nixos-rebuild switch --flake ".#"
```

As a side note, this is the codium flake file. Used to allow me to use any vscode extensions

```
# flake.nix
{
  inputs = {
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-utils.follows = "nix-vscode-extensions/flake-utils";
    nixpkgs.follows = "nix-vscode-extensions/nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        extensions = inputs.nix-vscode-extensions.extensions.${system};
        inherit (pkgs) vscode-with-extensions vscodium;

        packages.default = vscode-with-extensions.override {
          vscode = vscodium;
          vscodeExtensions = [
            extensions.vscode-marketplace.golang.go
            extensions.open-vsx-release.rust-lang.rust-analyzer
            extensions.vscode-marketplace.sourcegraph.cody-ai

            # # ai related
            extensions.vscode-marketplace.continue.continue
            extensions.vscode-marketplace.github.copilot
            extensions.vscode-marketplace.github.copilot-chat

            #dotnet
            extensions.vscode-marketplace.ms-dotnettools.csharp
            extensions.vscode-marketplace.ms-dotnettools.csdevkit


            # testing
            extensions.vscode-marketplace.ms-vscode-remote.remote-ssh
            extensions.vscode-marketplace.ms-vscode-remote.remote-containers
            extensions.vscode-marketplace.ms-azuretools.vscode-docker
            # ms-vscode-remote.vscode-remote-extensionpack # extension not available in pkgs
            # ms-vscode.remote-explorer # extension not available in pkgs
            # ms-vscode-remote.vscode-remote-extensionpack # extension not available in pkgs

            # foam.foam-vscode
            extensions.vscode-marketplace.gleam.gleam
            extensions.vscode-marketplace.mhutchie.git-graph
            extensions.vscode-marketplace.pkief.material-icon-theme
            extensions.vscode-marketplace.oderwat.indent-rainbow
            extensions.vscode-marketplace.bierner.markdown-emoji
            extensions.vscode-marketplace.bierner.emojisense
            extensions.vscode-marketplace.seatonjiang.gitmoji-vscode

            extensions.vscode-marketplace.bbenoist.nix
            extensions.vscode-marketplace.arrterian.nix-env-selector
            extensions.vscode-marketplace.jnoortheen.nix-ide
            extensions.vscode-marketplace.dracula-theme.theme-dracula
            extensions.vscode-marketplace.yzhang.markdown-all-in-one
            extensions.vscode-marketplace.esbenp.prettier-vscode
            extensions.vscode-marketplace.file-icons.file-icons
            extensions.vscode-marketplace.svelte.svelte-vscode
            extensions.vscode-marketplace.golang.go
            extensions.vscode-marketplace.ms-python.python
            extensions.vscode-marketplace.ms-toolsai.jupyter
            extensions.vscode-marketplace.antfu.icons-carbon
            extensions.vscode-marketplace.dbaeumer.vscode-eslint
            extensions.vscode-marketplace.bradlc.vscode-tailwindcss
            extensions.vscode-marketplace.kamikillerto.vscode-colorize
            extensions.vscode-marketplace.mechatroner.rainbow-csv
            extensions.vscode-marketplace.donjayamanne.githistory
            extensions.vscode-marketplace.davidanson.vscode-markdownlint
            extensions.vscode-marketplace.dart-code.flutter
            extensions.vscode-marketplace.mechatroner.rainbow-csv
            extensions.vscode-marketplace.james-yu.latex-workshop
            extensions.vscode-marketplace.shd101wyy.markdown-preview-enhanced

          ];
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ packages.default ];
          shellHook = ''
            printf "VSCodium with extensions:\n"
            codium --list-extensions
          '';
        };
      in
      {
        inherit packages devShells;
      }
    );
}
```
