vimrc_path="$HOME/.dotfiles/vimrc"
home_path="$HOME/.vimrc"

#the gitrc file

gitrc_path="$HOME/.dotfiles/gitconfig"
git_path="$HOME/.gitconfig"

tmuxrc_path="$HOME/.dotfiles/tmuxrc"
tmux_path="$HOME/.tmux.conf"

nbrc_path="$HOME/.dotfiles/nbrc"
nb_path="$HOME/.nbrc"

[ -f "$home_path" ] && echo ".vimrc file already exists. Aborting." || ln -s "$vimrc_path" $home_path && echo "Symbolic linking successful."

[ -f "$nb_path" ] && echo ".nbrc file is already present." || ln -s "$nbrc_path" $nb_path && echo "nb is successfully customized."

[ -f "$tmux_path" ] && echo ".tmux.conf file already exists. Aborting." || ln -s "$tmuxrc_path" $tmux_path && echo "Symbolic linking successful."

[ -f "$git_path" ] && echo ".git.config file already exists. Aborting." || ln -s "$gitrc_path" $git_path && echo ".git is successfully installed"

grep -q "source ~/.dotfiles/.alias" ~/.bashrc && echo "The file is already linked." || echo "source ~/.dotfiles/.alias" >> ~/.bashrc && echo "Linked successfully."

grep -q "source ~/.dotfiles/.prompt" ~/.bashrc && echo "The file is already linked." || echo "source ~/.dotfiles/.prompt" >> ~/.bashrc && echo "Linked successfully."

