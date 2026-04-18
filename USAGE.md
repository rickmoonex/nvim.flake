# Using This Flake

This flake provides a fully-configured Neovim setup with optional Obsidian integration.

## Available Outputs

### Packages

| Package | Description |
|---------|-------------|
| `nvim` (default) | Main Neovim package with all plugins |
| `nvim-obsidian` | Neovim with Obsidian mode enabled (opens daily note, shows vault in neo-tree) |
| `obsidian-util` | CLI helper for managing daily notes from the terminal |

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
          nvim-flake.packages.${system}.nvim-obsidian
          nvim-flake.packages.${system}.obsidian-util
        ];
      }];
    };

    # For Home Manager (standalone)
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [{
        home.packages = [
          nvim-flake.packages.x86_64-linux.nvim
          nvim-flake.packages.x86_64-linux.nvim-obsidian
          nvim-flake.packages.x86_64-linux.obsidian-util
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

              # Obsidian configuration
              obsidian = {
                vault_path = "~/Documents/MyVault";
                notes_subdir = "inbox";
                daily_notes_folder = "daily";
              };
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

### Obsidian Settings

These are configured via `nixCats` categories in your package definition:

| Option | Default | Description |
|--------|---------|-------------|
| `obsidian.vault_path` | `~/Vault` | Path to your Obsidian vault |
| `obsidian.notes_subdir` | `inbox` | Subdirectory for new notes |
| `obsidian.daily_notes_folder` | `daily` | Folder for daily notes |

Example configuration:

```nix
nvim.packageDefinitions.nvim = { pkgs, ... }: {
  categories = {
    general = true;
    gitPlugins = true;
    
    # Obsidian settings
    obsidian = {
      vault_path = "~/Documents/Obsidian/MyVault";
      notes_subdir = "notes";
      daily_notes_folder = "journal";
    };
  };
};
```

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

### nvim-obsidian

Neovim in Obsidian mode - automatically opens today's daily note, shows the vault in neo-tree, and enables all Obsidian keybindings:

```bash
nvim-obsidian           # Start in Obsidian mode
```

#### Obsidian Keybindings

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>oc` | n | Obsidian command palette |
| `<leader>l` | n | Follow link / show backlinks |
| `<leader>dd` | n | Open today's daily note |
| `<leader>dr` | n | Show unreviewed daily notes |
| `<leader>dx` | n | Toggle daily note done status |
| `<leader>dp` | n | Previous daily note |
| `<leader>dn` | n | Next daily note |
| `[` / `]` | n | Jump between headings (in markdown) |
| `<leader>cs` | v | Save code snippet to vault |
| `<leader>k` | v | Wrap selection as markdown link (URL from clipboard) |
| `<leader>p` | n | Paste image from clipboard |
| `<leader>ot` | n | Search tags across vault |
| `<leader>oo` | n | Find orphan notes |
| `<leader>ll` | n/v | Link word/selection to note |
| `[[` | i | Insert wiki-link (with telescope picker) |
| `<leader>z` | n | Toggle Zen Mode |
| `<leader>?` | n | Show Obsidian keybindings cheatsheet |

### obsidian-util

CLI helper for managing daily notes from the terminal:

```bash
# Add entries to today's daily note
obsidian-util daily journal "Had a great meeting"
obsidian-util daily task "Review PR #123"
obsidian-util daily note "Remember to check the docs"

# View or open daily note
obsidian-util daily show     # Print to stdout
obsidian-util daily open     # Open in nvim

# Search the vault
obsidian-util search "project alpha"

# Use custom vault path
obsidian-util --vault ~/Documents/MyVault daily journal "Entry text"
obsidian-util --vault ~/Documents/MyVault --daily-folder journal daily task "Task text"
```

---

## Platform Support

This flake supports both macOS and Linux:

- **macOS**: Uses `pngpaste` for clipboard image pasting
- **Linux**: Uses `xclip` (X11) and `wl-clipboard` (Wayland) for clipboard image pasting

The `img-clip-nvim` plugin automatically detects the available clipboard tool.

---

## Template Files

The flake includes templates for daily notes and new notes in the `templates/` directory. These are used by obsidian.nvim when creating new notes.
