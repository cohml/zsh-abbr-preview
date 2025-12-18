# zsh-abbr-preview

Preview [`zsh-abbr`](https://github.com/olets/zsh-abbr) abbreviation expansions as you type.

## Demo

```
$ abbr g=git
Added the regular user abbreviation `g`
$ g|  # "|" represents your cursor
→ git
```

Type an abbreviation and a preview of what it expands to will be displayed.

## Installation

Source `zsh-abbr-preview` in your `.zshrc` (either before or after sourcing `zsh-abbr`):

```zsh
source /path/to/zsh-abbr-preview/zsh-abbr-preview.plugin.zsh
```

Or use your plugin manager:

```zsh
# zinit
zinit light olets/zsh-abbr
zinit light cohml/zsh-abbr-preview

# oh-my-zsh
plugins=(... zsh-abbr zsh-abbr-preview)
```

## Configuration

Customize the preview prefix by setting this variable before sourcing the plugin:

```zsh
ZSH_ABBR_PREVIEW_PREFIX="..."  # default: "→ "
```

## Requirements

- `zsh-abbr`
- Zsh 5.0+

## How It Works

`zsh-abbr-preview` hooks into `zle-line-pre-redraw` to check if your current input matches an abbreviation. It uses `zsh-abbr`'s own expansion functions (`_abbr_regular_expansion` and `_abbr_global_expansion`) to ensure the preview logic stays in sync with actual abbreviation behavior.

The preview should respects all `zsh-abbr` configurations, including:
- `ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES` - glob patterns for valid prefixes (e.g., "`*; `")
- `ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES` - literal prefixes (e.g., "`sudo `")
- `ABBR_SPLIT_FN` - custom word splitting function

When an abbreviation is detected, its expansion is displayed below your prompt using `zle -M`. Multi-word abbreviations (e.g., `git s` → `git status`) are fully supported.

## License

MIT
