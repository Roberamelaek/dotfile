vimrc_path="$HOME/.dotfiles/vimrc"
home_path="$HOME/.vimrc"

if [ -f "$home_path" ]; then
	echo ".vimrc file already exsists aborting"
else
	ln -s "$vimrc_path" "$home_path"
	echo "The symboilc linking do sucssusfully"
fi

if grep -Fxq "source ~/.dotfiles/.alias" ~/.bashrc; then

	echo "Checking if the connection of the file..."
	echo "The file is already linked!."

else
	echo "Linking .alias to .bashrc"
	echo "source ~/.dotfiles/.alias">> ~/.bashrc
	echo "Linked sucssusfully"

fi

if grep -Fxq "source ~/.dotfiles/.prompt" ~/.bashrc; then

	echo "checking if the connection of the file..."
	echo "The file is already linked!."

else 
  echo "Linking .prompt to .bashrc..."
  echo "source ~/.dotfiles/.prompt">> ~/.bashrc
	echo "Linked sucssusfully"

fi



