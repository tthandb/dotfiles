# vim

Simplified Vim 9+ config — port of `../nvim/` without LSP, completion, treesitter, formatters, or linters. Just core editor behavior, fuzzy finder, file tree, git, and a theme.

## Install

```sh
bash install.sh
```

Symlinks `~/.vimrc` → `./.vimrc` (backing up any existing file), clones 14 plugins into `~/.vim/pack/plugins/start/`, installs the `fzf` binary if missing, and generates helptags. Re-run any time to update plugins (idempotent).

## Use

After running `install.sh`, just launch `vim`. Or ad-hoc without symlinking:

```sh
vim -u ~/dotfiles/.config/vim/.vimrc
```

## Requirements

- Vim 9+ (for native packages and `termguicolors`)
- `git`, `ripgrep`, `fd` (used by fzf and `:Rg`)
- `brew` on macOS (for installing the fzf binary; falls back to fzf's own installer otherwise)
- A Nerd Font terminal (for airline + powerline glyphs)

## Plugins

| Purpose | Plugin |
|---|---|
| Colorscheme | [tokyonight-vim](https://github.com/ghifarit53/tokyonight-vim) |
| Statusline | [vim-airline](https://github.com/vim-airline/vim-airline) + [themes](https://github.com/vim-airline/vim-airline-themes) |
| Fuzzy finder | [fzf](https://github.com/junegunn/fzf) + [fzf.vim](https://github.com/junegunn/fzf.vim) |
| File tree | [nerdtree](https://github.com/preservim/nerdtree) |
| Git porcelain | [vim-fugitive](https://github.com/tpope/vim-fugitive) |
| Git signs | [vim-gitgutter](https://github.com/airblade/vim-gitgutter) |
| Surround | [vim-surround](https://github.com/tpope/vim-surround) |
| Repeat (`.`) | [vim-repeat](https://github.com/tpope/vim-repeat) |
| Comment toggle | [vim-commentary](https://github.com/tpope/vim-commentary) |
| Auto-pairs | [auto-pairs](https://github.com/jiangmiao/auto-pairs) |
| Leap-style jump | [vim-sneak](https://github.com/justinmk/vim-sneak) |
| Highlight on yank | [vim-highlightedyank](https://github.com/machakann/vim-highlightedyank) |

## Keymaps

Leader is `<Space>`.

### Core

| Keys | Action |
|---|---|
| `jk` / `kj` | Esc (insert mode) |
| `<C-h/j/k/l>` | Window navigation |
| `<M-j>` / `<M-k>` | Move line down/up (n/i/v) |
| `<` / `>` (visual) | Indent, keep selection |

### Fuzzy finder

| Keys | Action |
|---|---|
| `<leader>fn` | Files |
| `<leader>fg` | Live grep (`:Rg`) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Helptags |
| `<leader>fr` | Recent files |
| `<leader>fR` | Marks |
| `<leader>fk` | Maps |
| `<leader>fc` | Commands |

### File tree

| Keys | Action |
|---|---|
| `<C-b>` | Toggle NERDTree |
| `<C-i>` | Focus NERDTree |

### Git

| Keys | Action |
|---|---|
| `<leader>gg` | `:Git` (fugitive status) |
| `<leader>gd` | `:Gdiffsplit` |
| `<leader>gl` | `:Git blame` |
| `<leader>gj` / `gk` | Next / previous hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Undo hunk |

### Sessions

| Keys | Action |
|---|---|
| `<leader>ws` | `:mksession! Session.vim` |
| `<leader>wr` | `:source Session.vim` |

Add `Session.vim` to your global gitignore.

### Sneak

`s` + 2 chars jumps forward with labels; `S` jumps backward. `;` / `,` to repeat / reverse.

### Built-in (no remap)

`gd` (local def), `K` (keyword help), `<C-]>` (tag jump), `*` / `#` (word search).

## Differences from nvim

- No LSP, no completion, no treesitter, no formatters/linters
- Folding is `indent`-based, not treesitter
- No Harpoon, auto-session, neogit, bufferline, which-key
- `tokyonight` style is `night` (vim port lacks `moon`)
- `<C-i>` mapping shadows `<Tab>` (jumplist forward) — same trade-off as the nvim config
