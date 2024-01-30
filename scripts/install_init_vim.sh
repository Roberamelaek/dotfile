

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
	echo "SOURCE init.vim file not found in ~
