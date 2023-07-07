vimrc_path="$HOME/.dotfiles/vimrc"
home_path="$HOME/.vimrc"

tmuxrc_path="$HOME/.dotfiles/tmuxrc"
tmux_path="$HOME/.tmux.conf"

[ -f "$home_path" ] && echo ".vimrc file already exists. Aborting." || ln -s "$vimrc_path" "$home_path" && echo "Symbolic linking successful."

[ -f "$tmux_path" ] && echo ".tmux.conf file already exists. Aborting." || ln -s "$tmuxrc_path" "$tmux_path" && echo "symbolic linking successful."

grep -q "source ~/.dotfiles/.alias" ~/.bashrc && echo "The file is already linked." || echo "source ~/.dotfiles/.alias" >> ~/.bashrc && echo "Linked successfully."

grep -q "source ~/.dotfiles/.prompt" ~/.bashrc && echo "The file is already linked." || echo "source ~/.dotfiles/.prompt" >> ~/.bashrc && echo "Linked successfully."

