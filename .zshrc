# === powerlevel10k instant prompt (must stay near top) =======================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === oh-my-zsh ===============================================================
export ZSH=~/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_DISABLE_COMPFIX=true
plugins=(git zsh-autosuggestions zsh-z zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# === sources =================================================================
[ -f ~/.fzf.zsh ]        && source ~/.fzf.zsh
[ -f ~/.p10k.zsh ]       && source ~/.p10k.zsh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# === nvm =====================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]         && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# === PATH ====================================================================
export BUN_INSTALL="$HOME/.bun"
export PATH="/opt/homebrew/opt/python@3.10/libexec/bin:$BUN_INSTALL/bin:$HOME/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# === aliases =================================================================
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
