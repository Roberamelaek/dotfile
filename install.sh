
#n to check if a package is installed
package_installed() {
    package="$1"
    dpkg -s "$package" >/dev/null 2>&1
}

# Check if Vim is installed
if ! package_installed "vim"; then
    echo "Installing Vim..."
    apt-get update
    apt-get install -y vim
else
    echo "Vim is already installed."
fi

# Check if Tmux is installed
if ! package_installed "tmux"; then
    echo "Installing Tmux..."
    apt-get update
    apt-get install -y tmux
else
    echo "Tmux is already installed."
fi

# Check if Git is installed
if ! package_installed "git"; then
    echo "Installing Git..."
    apt-get update
    apt-get install -y git
else
    echo "Git is already installed."
fi

# Set the paths for your configuration files
nbrc_path="$HOME/.dotfiles/nbrc"
tmuxrc_path="$HOME/.dotfiles/tmuxrc"
vimrc_path="$HOME/.dotfiles/vimrc"
gitconfig_path="$HOME/.dotfiles/gitconfig"
gitinstall_path="$HOME/.dotfiles/gitconfig/gitinstall.sh"

# Set the destination directories for the symbolic links
nbrc_dest="$HOME/.nbrc"
tmuxrc_dest="$HOME/.tmux.conf"
vimrc_dest="$HOME/vimrc"

# Function to create or recreate symbolic links
create_symlink() {
    source_file="$1"
    dest_file="$2"

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

