apt-get update
apt-get install neovim

SOURCE="$HOME/.dotfiles/.config/init.vim"
DESTINATION="$HOME/.config/nvim/init.vim"
NVIM_CONFIG="$HOME/.config/nvim/init.vim"

if [ -f "$SOURCE" ]; then

	if [ -f "$DESTINATION" ]; then

		rm "$DESTINATION"

		echo "Existing init.vim deleted."

	fi

	ln -s "$SOURCE" "$DESTINATION"
	echo "init.vim copied successfully."
else

    ln -s "$SOURCE" "$DESTINATION"
    
	echo "SOURCE init.vim file not found in ~/.config/nvim/init.vim"
    echo "init.vim copied successfully"
fi


# Define plugin list
PLUGINS=(
    "tpope/vim-surround"
    "preservim/nerdtree"
    "tpope/vim-commentary"
    "vim-airline/vim-airline"
    "lifepillar/pgsql.vim"
    "ap/vim-css-color"
    "rafi/awesome-vim-colorschemes"
    "neoclide/coc.nvim"
    "ryanoasis/vim-devicons"
    "tc50cal/vim-terminal"
    "preservim/tagbar"
    "terryma/vim-multiple-cursors"
)

# Add plugin installations to Neovim configuration file

# Open Neovim and install plugins
nvim +PlugInstall +qall

