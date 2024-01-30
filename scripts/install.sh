#!/bin/bash
set -e

# Check if a package is installed
package_installed() {
    package="$1"
    command -v "$package" >/dev/null 2>&1
}

# List of packages to check and install
packages=("vim" "tmux" "git" "neovim")

for package in "${packages[@]}"; do
    if ! package_installed "$package"; then
        echo "Installing $package..."
        apt-get update
        apt-get install -y "$package"
    else
        echo "$package is already installed."
    fi
done

# Set the paths for your configuration files
nbrc_path="$HOME/.dotfiles/nbrc"
tmuxrc_path="$HOME/.dotfiles/tmuxrc"
vimrc_path="$HOME/.dotfiles/vimrc"
gitconfig_path="$HOME/.dotfiles/gitconfig"
gitinstall_path="$HOME/.dotfiles/gitconfig/gitinstall.sh"
init_vim_path="$HOME/.dotfiles/.config/nvim/init.vim"

# Set the destination directories for the symbolic links
nbrc_dest="$HOME/.nbrc"
tmuxrc_dest="$HOME/.tmux.conf"
vimrc_dest="$HOME/.vimrc"
init_vim_dest="$HOME/.config/nvim/init.vim"

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
create_symlink "$init_vim_path" "$init_vim_dest"

# Run the gitinstall.sh script
bash "$gitinstall_path"

# Array of file names to source
files=("alias" "prompt")

# Add source commands to .bashrc for each file
for file in "${files[@]}"; do
    filepath="$HOME/.dotfiles/.$file"
    if [[ -f "$filepath" ]]; then
        echo "source $filepath" >> "$HOME/.bashrc"
    fi
done
