# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="/home/binhnguyen3/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-z zsh-syntax-highlighting)

#Go path
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/home/binhnguyen3/golib
export PATH=$PATH:$GOPATH/bin

#Java path
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

export ANDROID_SDK=/home/binhnguyen3/Android/Sdk
export PATH=$PATH:/home/binhnguyen3/Android/Sdk/platform-tools/


source $ZSH/oh-my-zsh.sh

echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/binhnguyen3/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/binhnguyen3/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/binhnguyen3/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/binhnguyen3/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias luamake=/home/binhnguyen3/Downloads/lua-language-server/3rd/luamake/luamake
