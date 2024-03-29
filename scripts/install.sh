#!/bin/bash
set -e

# Check if a package is installed
package_installed() {
    package="$1"
    dpkg -l | grep -qE "^ii\s+$package\s"
}

# List of packages to check and install
packages=("vim" "tmux" "git")

for package in "${packages[@]}"; do
    if ! package_installed "$package"; then
        echo "Installing $package..."
        sudo apt update
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done

echo "---------------------------"

if ! grep -qF "source $HOME/.dotfiles/.alias" ~/.bashrc ; then
        echo "source $HOME/.dotfiles/.alias"  >> ~/.bashrc

        echo "source $HOME/.dotfiles/.prompt" >> ~/.bashrc

fi


echo "------------------------------"


# Set the paths for your configuration files
nbrc_path="$HOME/.dotfiles/nbrc"
tmuxrc_path="$HOME/.dotfiles/tmuxrc"
vimrc_path="$HOME/.dotfiles/vimrc"
gitconfig_path="$HOME/.dotfiles/gitconfig"
gitinstall_path="$HOME/.dotfiles/gitconfig/gitinstall.sh"

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
mkdir -p $HOME/.config/nvim

# Create/initiate plugin manager (assuming you're using vim-plug)
curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Define Neovim configuration file

bash $HOME/.dotfiles/scripts/install_init_vim.sh
