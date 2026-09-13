# vim

Minimal Vim 9+ config. Four plugins, twenty mappings, no external binary
dependency beyond `git`. File finding, project grep, symbol lookup and
refactoring run on Vim built-ins, so it works unchanged on locked-down machines
where `ripgrep`, `fd`, `fzf` and `node` cannot be installed.

Anything Vim can already do is left to Vim. The tables below document the
native commands, not just the mappings.

## Install

From a clean machine, in this order:

```sh
git clone https://github.com/tthandb/dotfiles ~/dotfiles
bash ~/dotfiles/make-symlinks.sh
bash ~/dotfiles/.config/vim/install.sh
```

`make-symlinks.sh` links `~/.config` to the repo. `install.sh` owns `~/.vimrc`
and the plugins; the two do not overlap. Either order works, and both are safe
to re-run.

`~/.vimrc` is linked to the physical path under `~/dotfiles/`, not through
`~/.config`, so running `install.sh` as `~/.config/vim/install.sh` or as
`~/dotfiles/.config/vim/install.sh` produces the same link and no repeated
backups.

Plugins go to `~/.vim/`, which is outside the repo. Do not add `.vim` to the
`FILES` list in `make-symlinks.sh` or every plugin checkout ends up staged.

`install.sh` symlinks `~/.vimrc` → `./.vimrc` (backing up a real file once,
replacing a stale symlink silently), clones the plugins into
`~/.vim/pack/plugins/start/`, creates `~/.vim/undo`, generates helptags, and
removes plugin directories no longer listed. Idempotent.

An environment report is printed first (`vim` version, `+clipboard`, `ctags`,
`+terminal`) so you know which features that machine supports.

| Env var | Effect |
| --- | --- |
| `VIM_OPTIONAL=1` | Also install the optional plugin set |
| `VIM_NO_PRUNE=1` | Keep plugin directories no longer listed |

Ad-hoc, without symlinking:

```sh
vim -u ~/dotfiles/.config/vim/.vimrc
```

## Requirements

- Vim 9+ (8.2.4325+ works, minus fuzzy `wildoptions`)
- `git`

Optional, degrades gracefully:

- `ctags` — enables `<C-]>` and `:Ctags`. Without it use `[I`.
- `+clipboard` — otherwise `pbcopy`/`pbpaste` mappings are defined on macOS.
- `+terminal` — for `:terminal`.

## Plugins

| Purpose | Plugin |
| --- | --- |
| Surround | [vim-surround](https://github.com/tpope/vim-surround) |
| Comment toggle | [vim-commentary](https://github.com/tpope/vim-commentary) |
| `.` support for the two above | [vim-repeat](https://github.com/tpope/vim-repeat) |
| Git porcelain | [vim-fugitive](https://github.com/tpope/vim-fugitive) |

Optional, install with `VIM_OPTIONAL=1`:

| Purpose | Plugin |
| --- | --- |
| `cin(`, `da,`, `ci2{` | [targets.vim](https://github.com/wellle/targets.vim) |
| Case-aware substitute, `crs` `crc` `crm` | [vim-abolish](https://github.com/tpope/vim-abolish) |
| Hunk signs in the gutter | [vim-gitgutter](https://github.com/airblade/vim-gitgutter) |
| Two-char motion | [vim-sneak](https://github.com/justinmk/vim-sneak) |
| Highlight on yank | [vim-highlightedyank](https://github.com/machakann/vim-highlightedyank) |
| `:Rename` `:Move` `:Delete` | [vim-eunuch](https://github.com/tpope/vim-eunuch) |
| Async `:Make` | [vim-dispatch](https://github.com/tpope/vim-dispatch) |

Fuzzy matching, file browsing, statusline, `:s` preview and the colorscheme are
all handled by Vim itself. Three bundled packages are loaded: `matchit`,
`cfilter`, `editorconfig`.

## Colorscheme

`habamax`, shipped with Vim. Change the last `colorscheme` line in `.vimrc` to
switch; no install needed. All of these support true colour.

| Scheme | Look |
| --- | --- |
| `habamax` | Muted dark, low-saturation. The general-purpose default. |
| `retrobox` | Gruvbox port. Warm, retro, high contrast. |
| `sorbet` | Dark with a cool blue-grey base. |
| `wildcharm` | Vibrant, saturated, closest to a modern Neovim theme. |
| `zaibatsu` | Very dark purple base. |
| `lunaperche` | Near-monochrome with a few accent colours. |
| `quiet` | Monochrome; syntax carried by bold and italic only. |

`:colorscheme <Tab>` cycles through everything available.

## Mappings

Leader is `<Space>`. This is the complete list.

| Keys | Action |
| --- | --- |
| `jk` | Esc (insert mode) |
| `<leader>f` | `:find` with the fuzzy popup already open |
| `<leader>b` | `:buffer` with the fuzzy popup already open |
| `<leader>*` | `:Grep` the word under the cursor (also works on a visual selection) |
| `<leader>/` | Clear search highlight |
| `]q` / `[q` | Next / previous quickfix entry |
| `]e` / `[e` | Move line or selection down / up |
| `<` / `>` (visual) | Indent, keep selection |
| `-` | Open netrw in the current file's directory |
| `<leader>gs` | `:Git` (fugitive status) |
| `<leader>gb` | `:Git blame` |
| `<leader>gd` | `:Gdiffsplit` |
| `,` `.` `(` (insert) | Insert an undo break point |
| `q` (quickfix window) | Close quickfix |

On machines where Vim lacks `+clipboard`, four extra mappings are defined:
`<leader>y` (operator), `<leader>Y` (line), `<leader>y` (visual) and
`<leader>p`, backed by `pbcopy` / `pbpaste`. With `+clipboard` use `"+y` and
`"+p` directly.

## Commands

| Command | Action |
| --- | --- |
| `:Grep {pattern}` | Search the project into the quickfix list |
| `:Ctags` | Regenerate `tags` (requires `ctags`) |
| `:Trim` | Strip trailing whitespace |
| `:W` | Write with `sudo` |

`:Grep` uses `git grep` inside a repository and `grep -rn` outside one, chosen
at startup and on every `:cd`.

## Native commands

Nothing below is mapped. These are the commands the config is built around.

### Finding files

| Command | Action |
| --- | --- |
| `:find {frag}<Tab>` | Open a file anywhere under the project |
| `:sfind` / `:vert sfind` | Same, in a horizontal / vertical split |
| `:b {frag}<Tab>` | Switch buffer |
| `<C-^>` | Alternate buffer |
| `:bn` / `:bp` / `:bd` | Next / previous / delete buffer |
| `:browse oldfiles` | Recently edited files |
| `gf` | Open the file path under the cursor |
| `:e %:h/<Tab>` | Open a file next to the current one |

`path` is `.,,**` and `wildoptions` includes `fuzzy`, so `:find usrctrl<Tab>`
matches `src/user/UserController.ts`. `wildignore` excludes `node_modules`,
`dist`, `.git`, build output and binaries.

### Quickfix

| Command | Action |
| --- | --- |
| `:copen` / `:cclose` | Open / close the list |
| `:cnext` / `:cprev` | Move through entries |
| `:cfirst` / `:clast` | Jump to the ends |
| `:Cfilter {pat}` | Keep only matching entries |
| `:Cfilter! {pat}` | Drop matching entries |
| `:cdo {cmd}` | Run a command on every entry |
| `:cfdo {cmd}` | Run a command once per file |
| `:colder` / `:cnewer` | Move through previous quickfix lists |

Quickfix opens automatically after `:grep` or `:make` when there are results.

### Symbols

| Command | Action |
| --- | --- |
| `[I` | List every occurrence of the word under the cursor |
| `]I` | Same, from the cursor line down |
| `[i` | Show only the first occurrence |
| `[d` / `[D` | Same, for `#define` |
| `<C-]>` | Jump to tag |
| `g<C-]>` | Jump to tag, menu when ambiguous |
| `<C-t>` | Jump back |
| `<C-w> }` | Show the definition in a preview window |
| `<C-w> z` | Close the preview window |
| `:tselect` / `:tjump` | Pick from matching tags |

`[I` needs no tags file and no language server.

### Windows

| Command | Action |
| --- | --- |
| `<C-w> h/j/k/l` | Move between windows |
| `<C-w> w` | Cycle windows |
| `<C-w> s` / `<C-w> v` | Split horizontally / vertically |
| `<C-w> q` / `<C-w> o` | Close this / close all others |
| `<C-w> =` | Equalise sizes |
| `<C-w> H/J/K/L` | Move the window itself |

`<C-h>` is deliberately not mapped: netrw claims it and a global mapping makes
`:Explore` fail with `E225`.

### Editing

| Command | Action |
| --- | --- |
| `*` then `cgn`, then `.` | Change every occurrence, `n` to skip one |
| `"_d` | Delete into the black hole register |
| `P` (visual) | Paste over a selection without clobbering the register |
| `"0p` | Paste the last yank, unaffected by intervening deletes |
| `"Ayy` | Append to register `a` |
| `<C-r>a` | Insert register `a` (insert and command-line mode) |
| `<C-r><C-w>` | Insert the word under the cursor into the command line |
| `<C-r>=` | Evaluate an expression into the buffer |
| `g<C-a>` (visual) | Turn a column of zeros into 1, 2, 3, … |
| `gv` | Reselect the last visual selection |
| `o<Esc>` / `O<Esc>` | Blank line below / above |
| `@@` | Replay the last macro |
| `q:` / `q/` | Command-line window: edit history as a buffer |
| `<C-f>` (command line) | Switch into that window mid-command |
| `g;` / `g,` | Walk the changelist |
| `` `. `` / `gi` | Last edit / resume insert there |
| `<C-o>` / `<C-i>` | Walk the jumplist |

### Completion

Insert mode, all built in:

| Keys | Source |
| --- | --- |
| `<C-n>` / `<C-p>` | Buffers |
| `<C-x><C-f>` | File paths |
| `<C-x><C-l>` | Whole lines |
| `<C-x><C-]>` | Tags |
| `<C-x><C-o>` | Omni, filetype-aware |
| `<C-y>` / `<C-e>` | Accept / dismiss |

### Terminal

| Command | Action |
| --- | --- |
| `:bo term ++rows=15` | Terminal in a split |
| `<C-w> N` | Terminal-normal mode: scroll, search, yank with normal motions |
| `i` | Resume the shell |
| `<C-w> "a` | Paste register `a` into the terminal |

### Sessions

| Command | Action |
| --- | --- |
| `:mksession! .vimsession` | Save layout |
| `vim -S .vimsession` | Restore it |

Add `.vimsession` to your global gitignore.

## Workflows

### Project-wide rename

```vim
:Grep OldName
:Cfilter! test
:cfdo %s/OldName/NewName/ge | update
```

`:cdo` runs once per match, `:cfdo` once per file — faster with `%s`.
`:Cfilter` narrows the list before you commit to the change.

With vim-abolish installed, `%Subvert/old_name/new_name/g` handles
`old_name`, `oldName` and `OLD_NAME` in one pass.

### Selective rename

Put the cursor on the identifier, press `*` then `cgn`, type the replacement,
press `<Esc>`. Then `.` applies the same change at the next match and `n` skips
one. Matches are visited one at a time, unlike multi-cursor.

### Operate on matching lines

```vim
:g/TODO/d
:v/error/d
:g/^import/normal @a
:g/console\.log/normal A // FIXME
:g/^/m0
```

### Run a macro over a range

```vim
qa … q
:%normal @a
:'<,'>normal @a
:g/^func /normal @a
```

A broken macro is just text: `"ap`, edit it, `"ay$`.

### Filter through a shell command

```vim
:%!jq .
:'<,'>!sort -u
:'<,'>!column -t
:r !git log --oneline -20
```

### Per-project settings

Drop a `.vimlocal` at the repository root; it is sourced on startup.

```vim
set makeprg=npm\ run\ typecheck
set path+=src/**,test/**
set suffixesadd+=.vue
```

Then `:make` sends errors to the quickfix list and `]q` / `[q` walk them.
`:compiler <Tab>` lists the bundled compiler definitions.

## Notes

- `incsearch` highlights `:s`, `:g` and `:v` patterns as you type, so no
  substitute-preview plugin is needed.
- `matchit` extends `%` to `if`/`endif`, HTML tags and other filetype pairs,
  and adds `g%`, `[%`, `]%`.
- `cfilter` provides `:Cfilter` and `:Lfilter`.
- Persistent undo lives in `~/.vim/undo`, so `:earlier 10m`, `g-` and `g+` work
  across restarts. `:undolist` shows the branches.
- `:h {topic}<Tab>` fuzzy-matches help topics.
