user=$USER
dir=~/dotfiles
olddir=/home/$user/dotfiles_old

files=".zshrc .gitconfig .p10k.zsh .ideavimrc .tmux.conf .config"

echo -n "Creating $olddir for backup of any existing dotfiles in home/$user ..."
mkdir -p $olddir
echo "done"

echo -n "Moving to $dir directory ..."
cd $dir
echo "done"

for file in $files; do
    echo "Moving any existing dotfiles from home/$user to $olddir"
    mv ~/$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done
