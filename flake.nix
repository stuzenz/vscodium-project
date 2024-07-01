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
            extensions.vscode-marketplace.dracula-theme.theme-dracula
            extensions.vscode-marketplace.svelte.svelte-vscode
            extensions.vscode-marketplace.golang.go
            extensions.vscode-marketplace.ms-python.python
            extensions.vscode-marketplace.ms-toolsai.jupyter
            extensions.vscode-marketplace.antfu.icons-carbon
            extensions.vscode-marketplace.file-icons.file-icons
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
