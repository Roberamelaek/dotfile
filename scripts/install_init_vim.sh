apt-get update
apt-get install neovim

SOURCE="$HOME/.dotfiles/.config/nvim/init.vim"
DESTINATION="$HOME/.config/nvim/init.vim"

if [ -f "$SOURCE" ]; then

	if [ -f "$DESTINATION" ]; then

		rm "$DESTINATION"

		echo "Existing init.vim deleted."

	fi

	cp "$SOURCE" "$DESTINATION"
	echo "init.vim copied successfully."
else

    cp "$SOURCE" "$DESTINATION"
    
	echo "SOURCE init.vim file not found in ~/.config/nvim/init.vim"
    echo "init.vim copied successfully"