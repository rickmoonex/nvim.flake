# nvim.flake

My NeoVim flake using NixCats

Still very much WIP, check back soon I guess...

## How to use

Add this flake as a flake input:

```nix
{
    inputs = {
        nvimflake.url = "github:rickmoonex/nvim.flake";
    };
}
```

Then simply install as a Nix package:

```nix
home.packages = [
    (inputs.nvimflake.packages.${pkgs.system}.nvim)
];
```
