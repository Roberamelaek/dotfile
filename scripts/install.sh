#!/bin/bash
set -e

# Check if a package is installed
package_installed() {
    package="$1"
    command -v "$package" >/dev/null 2>&1
}

# List of packages to check and install
packages=("vim" "tmux" "git")

for package in "${packages[@]}"; do
    if ! package_installed "$package"; then
        echo "Installing $package..."
        apt-get update
        apt-get install -y "$package"
    else
        echo "$package is already installed."
    fi
done


echo "---------------------------"

if ! grep -qF "source /.dotfiles/.alias" ~/.bashrc ; then
	echo "source /.dotfiles/.alias"  >> ~/.bashrc

	echo "source /.dotfiles/.prompt" >> ~/.bashrc

fi
		

echo "------------------------------"


# Set the paths for your configuration files
nbrc_path="$HOME/.dotfiles/nbrc"
tmuxrc_path="$HOME/.dotfiles/tmuxrc"
vimrc_path="$HOME/.dotfiles/vimrc"
gitconfig_path="$HOME/.dotfiles/gitconfig"
gitinstall_path="/.dotfiles/gitconfig/gitinstall.sh"

# Set the destination directories for the symbolic links
nbrc_dest="$HOME/.nbrc"
tmuxrc_dest="$HOME/.tmux.conf"
vimrc_dest="$HOME/.vimrc"

# Function to create or recreate symbolic links
create_symlink() {
    local source_file="$1"
    local dest_file="$2"

    if [[ -e "$dest_file" || -L "$dest_file" ]]; then
        rm "$dest_file"
        echo "Deleted existing file or symbolic link: $dest_file"
    fi

    ln -s "$source_file" "$dest_file"
    echo "Created symbolic link: $dest_file"
}

# Create or recreate symbolic links for the configuration files
create_symlink "$nbrc_path" "$nbrc_dest"
create_symlink "$tmuxrc_path" "$tmuxrc_dest"
create_symlink "$vimrc_path" "$vimrc_dest"

# Run the gitinstall.sh script
bash "$gitinstall_path"

# Array of file names to source
files=("prompt" "alias")

# Add source commands to .bashrc for each file
for file in "${files[@]}"; do
    filepath="$HOME/.dotfiles/.$file"
    if [[ -f "$filepath" ]]; then
        echo "source $filepath" >> "$HOME/.bashrc"
    fi
done

#!/bin/bash

# Create directory for Neovim configuration if it doesn't exist
mkdir -p /.config/nvim

# Create/initiate plugin manager (assuming you're using vim-plug)
curl -fLo /.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Define Neovim configuration file
NVIM_CONFIG=/.config/nvim/init.vim
bash ./scripts/install_init_vim.sh
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
echo 'call plug#begin()' > $NVIM_CONFIG
for PLUGIN in "${PLUGINS[@]}"; do
    echo "Plug 'https://github.com/$PLUGIN'" >> $NVIM_CONFIG
done
echo 'call plug#end()' >> $NVIM_CONFIG

# Open Neovim and install plugins
nvim +PlugInstall +qall

