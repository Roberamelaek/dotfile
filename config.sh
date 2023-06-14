vimrc_path="$HOME/dotfiles/vimrc"
home_path="$HOME/.vimrc"

if [ -f "$home_path" ]; then
	echo "Error:.vimrc file already exsists aborting"
else
	ln -s "$vimrc_path" "$home_path"
	echo "The symboilc linking do sucssusfully"
fi
