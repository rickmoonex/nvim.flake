# Using This Flake

This flake provides a fully-configured Neovim setup.

## Available Outputs

### Packages

| Package | Description |
|---------|-------------|
| `nvim` (default) | Main Neovim package with all plugins |

### Modules

| Module | Description |
|--------|-------------|
| `homeModules.default` | Home Manager module |
| `nixosModules.default` | NixOS module |

### Overlays

| Overlay | Description |
|---------|-------------|
| `overlays.default` | Default overlay |
| `overlays.nvim` | Neovim-specific overlay |

---

## Installation Methods

### Method 1: Standalone Package (Quick Install)

Add to your flake inputs and install the package directly:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nvim-flake.url = "github:rickmoonex/nvim.flake";
  };

  outputs = { nixpkgs, nvim-flake, ... }: {
    # For NixOS
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";  # or "aarch64-linux", "aarch64-darwin", etc.
      modules = [{
        environment.systemPackages = [
          nvim-flake.packages.${system}.nvim
        ];
      }];
    };

    # For Home Manager (standalone)
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [{
        home.packages = [
          nvim-flake.packages.x86_64-linux.nvim
        ];
      }];
    };
  };
}
```

### Method 2: Home Manager Module (Recommended for Customization)

Use the Home Manager module to customize the configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nvim-flake.url = "github:rickmoonex/nvim.flake";
  };

  outputs = { nixpkgs, home-manager, nvim-flake, ... }: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        nvim-flake.homeModules.default
        {
          # Enable the nvim package
          nvim.enable = true;

          # Customize categories and settings
          nvim.packageDefinitions.nvim = { pkgs, ... }: {
            categories = {
              general = true;
              gitPlugins = true;
              customPlugins = true;
            };
          };
        }
      ];
    };
  };
}
```

### Method 3: NixOS Module

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nvim-flake.url = "github:rickmoonex/nvim.flake";
  };

  outputs = { nixpkgs, nvim-flake, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nvim-flake.nixosModules.default
        {
          nvim.enable = true;
        }
      ];
    };
  };
}
```

### Method 4: Using Overlays

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nvim-flake.url = "github:rickmoonex/nvim.flake";
  };

  outputs = { nixpkgs, nvim-flake, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ nvim-flake.overlays.default ];
    };
  in {
    # Now pkgs.nvim is available
    packages.${system}.default = pkgs.nvim;
  };
}
```

---

## Configuration Options

### Package Categories

| Category | Description |
|----------|-------------|
| `general` | Core plugins and LSPs (telescope, treesitter, lualine, etc.) |
| `gitPlugins` | Git-related plugins from flake inputs |
| `customPlugins` | Custom plugins |
| `test` | Test category with example environment variables |

---

## Using the Packages

### nvim

Standard Neovim with all configured plugins:

```bash
nvim                    # Start neovim
nvim myfile.lua         # Open a file
```

---

## Platform Support

This flake supports both macOS and Linux. On Linux it installs `xclip` (X11) and `wl-clipboard` (Wayland) as clipboard providers.
