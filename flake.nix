{
  description = "My NeoVim flake using nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-maud-fmt" = {
      url = "github:eboody/maud-fmt.nvim";
      flake = false;
    };

    "plugins-checkmate" = {
      url = "github:bngarren/checkmate.nvim";
      flake = false;
    };

    # Rhai language server (rhaiscript/lsp). Builds the `rhai` binary which
    # provides `rhai lsp stdio` plus formatting. Not packaged in nixpkgs.
    "rhai-lsp-src" = {
      url = "github:rhaiscript/lsp/2f1fcd73f43b909d1d5e96123516e599b9aaaa88";
      flake = false;
    };

    # Tree-sitter grammar for Rhai (no grammar in nixpkgs' withAllGrammars).
    "tree-sitter-rhai-src" = {
      url = "github:elkowar/tree-sitter-rhai";
      flake = false;
    };
  };

  # see :help nixCats.flake.outputs
  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

    extra_pkg_config = {
      allowUnfree = true;
    };
    # management of the system variable is one of the harder parts of using flakes.

    # so I have done it here in an interesting way to keep it out of the way.
    # It gets resolved within the builder itself, and then passed to your
    # categoryDefinitions and packageDefinitions.

    # this allows you to use ${pkgs.stdenv.hostPlatform.system} whenever you want in those sections
    # without fear.

    # see :help nixCats.flake.outputs.overlays
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      [
        # This overlay grabs all the inputs named in the format
        # `plugins-<pluginName>`
        # Once we add this overlay to our nixpkgs, we are able to
        # use `pkgs.neovimPlugins`, which is a set of our plugins.
        (utils.standardPluginOverlay inputs)
        # add any other flake overlays here.

        # when other people mess up their overlays by wrapping them with system,
        # you may instead call this function on their overlay.
        # it will check if it has the system in the set, and if so return the desired overlay
        # (utils.fixSystemizedOverlay inputs.codeium.overlays
        #   (system: inputs.codeium.overlays.${system}.default)
        # )
      ];

    # see :help nixCats.flake.outputs.categories
    # and
    # :help nixCats.flake.outputs.categoryDefinitions.scheme
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: let
      # Rhai language server: builds the `rhai` CLI from rhaiscript/lsp.
      # Upstream has no committed Cargo.lock, so we supply our own
      # (generated once, stored at ./nix/rhai-lsp-Cargo.lock).
      rhai-lsp = pkgs.rustPlatform.buildRustPackage {
        pname = "rhai-lsp";
        version = "unstable-2022-10-26";
        src = inputs.rhai-lsp-src;
        cargoLock.lockFile = ./nix/rhai-lsp-Cargo.lock;
        postPatch = ''
          cp ${./nix/rhai-lsp-Cargo.lock} Cargo.lock
        '';
        cargoBuildFlags = ["-p" "rhai-cli"];
        doCheck = false;
        meta = {
          description = "Language server for the Rhai scripting language";
          mainProgram = "rhai";
        };
      };

      # Tree-sitter grammar for Rhai, built so nvim-treesitter can use it.
      tree-sitter-rhai =
        pkgs.tree-sitter.buildGrammar {
          language = "rhai";
          version = "unstable-2024-12-16";
          src = inputs.tree-sitter-rhai-src;
        };
    in {
      # to define and use a new category, simply add a new list to a set here,
      # and later, you will include categoryname = true; in the set you
      # provide when you build the package using this builder function.
      # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

      # lspsAndRuntimeDeps:
      # this section is for dependencies that should be available
      # at RUN TIME for plugins. Will be available to PATH within neovim terminal
      # this includes LSPs
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          # LSP
          typescript-language-server
          stylua
          biome
          alejandra
          terraform-ls
          markdown-oxide
          prettierd
          nushell
          zls
          zig
          rust-analyzer
          rustc
          cargo
          rustfmt
          clippy
          vscode-langservers-extracted
          emmet-language-server
          buf
          rhai-lsp

          # Linting
          tflint
          terraform
          nu-lint

          # Runtime dev
          ripgrep
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.xclip pkgs.wl-clipboard ];
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        gitPlugins = [
          pkgs.neovimPlugins."maud-fmt"
          pkgs.neovimPlugins."checkmate"
        ];
        general = with pkgs.vimPlugins; [
          catppuccin-nvim
          neo-tree-nvim
          plenary-nvim
          nui-nvim
          nvim-web-devicons
          nvim-notify
          # All bundled grammars plus our custom-built Rhai grammar.
          (nvim-treesitter.withPlugins (p:
            nvim-treesitter.allGrammars
            ++ [tree-sitter-rhai]))
          noice-nvim
          telescope-nvim
          telescope-ui-select-nvim
          vim-tmux-navigator
          alpha-nvim
          nvim-autopairs
          bufferline-nvim
          nvim-lspconfig
          lualine-nvim
          cmp-nvim-lsp
          luasnip
          nvim-cmp
          cmp_luasnip
          friendly-snippets
          nvim-autopairs
          none-ls-nvim
          render-markdown-nvim
          mini-nvim
          outline-nvim
          vim-table-mode
          zen-mode-nvim
          twilight-nvim
          nvim-ts-autotag
        ];
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      optionalPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [];
        general = with pkgs.vimPlugins; [];
      };

      # shared libraries to be added to LD_LIBRARY_PATH
      # variable available to nvim runtime
      sharedLibraries = {
        general = with pkgs; [
          # libgit2
        ];
      };

      # environmentVariables:
      # this section is for environmentVariables that should be available
      # at RUN TIME for plugins. Will be available to path within neovim terminal
      environmentVariables = {
        test = {
          CATTESTVAR = "It worked!";
        };
      };

      # If you know what these are, you can provide custom ones by category here.
      # If you dont, check this link out:
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      extraWrapperArgs = {
        test = [
          ''--set CATTESTVAR2 "It worked again!"''
        ];
      };

      # lists of the functions you would have passed to
      # python.withPackages or lua.withPackages
      # do not forget to set `hosts.python3.enable` in package settings

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      python3.libraries = {
        test = _: [];
      };
      # populates $LUA_PATH and $LUA_CPATH
      extraLuaPackages = {
        test = [(_: [])];
      };
    };

    # And then build a package with specific categories from above here:
    # All categories you wish to include must be marked true,
    # but false may be omitted.
    # This entire set is also passed to nixCats for querying within the lua.

    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # These are the names of your packages
      # you can include as many as you wish.
      nvim = {
        pkgs,
        name,
        ...
      }: {
        # they contain a settings set defined above
        # see :help nixCats.flake.outputs.settings
        settings = {
          suffix-path = true;
          suffix-LD = true;
          wrapRc = true;
          # IMPORTANT:
          # your alias may not conflict with your other packages.
          aliases = ["vim"];
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
        };
        # and a set of categories that you want
        # (and other information to pass to lua)
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;
          example = {
            youCan = "add more than just booleans";
            toThisSet = [
              "and the contents of this categories set"
              "will be accessible to your lua with"
              "nixCats('path.to.value')"
              "see :help nixCats"
            ];
          };
        };
      };
    };
    # In this section, the main thing you will need to do is change the default package name
    # to the name of the packageDefinitions entry you wish to use as the default.
    defaultPackageName = "nvim";
  in
    # see :help nixCats.flake.outputs.exports
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      # this is just for using utils such as pkgs.mkShell
      # The one used to build neovim is resolved inside the builder
      # and is passed to our categoryDefinitions and packageDefinitions
      pkgs = import nixpkgs {inherit system;};
    in {
      # these outputs will be wrapped with ${system} by utils.eachSystem

      # this will make a package out of each of the packageDefinitions defined above
      # and set the default package to the one passed in here.
      packages = utils.mkAllWithDefault defaultPackage;

      # choose your package for devShell
      # and add whatever else you want in it.
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      # we also export a nixos module to allow reconfiguration from configuration.nix
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      # and the same for home manager
      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      # these outputs will be NOT wrapped with ${system}

      # this will make an overlay out of each of the packageDefinitions defined above
      # and set the default overlay to the one named here.
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
