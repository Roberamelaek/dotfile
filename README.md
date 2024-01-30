# Dotfiles: Configuration Files for Vim, Tmux, and Git

Welcome to my dotfiles repository! This repository contains my personal configuration files for Vim, Tmux, Git, and Neovim, along with installation scripts. Feel free to use these configurations as a starting point and customize them to suit your preferences.

## Contents

1. `vimrc`: Configuration file for Vim.
2. `tmuxrc`: Configuration file for Tmux.
3. `gitconfig/`: Git configuration files.
    - `gitinstall.sh`: Git installation script.
4. `scripts/`: Installation script.
    - `install.sh`: Installation script for basic setup.
    - `install_enhanced.sh`: Enhanced installation script for additional configurations.
5. `.config/nvim/init.vim`: Configuration file for Neovim.

## Installation

Follow these steps to install and use the configurations provided in this repository:

### Step 1: Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/Roberamelaek/dotfile.git .dotfiles
```

### Step 2: Change into the Repository Directory

Change into the repository directory:

```bash
cd .dotfiles
```

### Step 3: Run the Basic Installation Script

Run the basic installation script to set up the configurations:

```bash
sh scripts/install.sh
```

This script installs Vim, Neovim, Tmux, and Git if they are not already installed, and copies the configuration files to your home directory (~/).

### Step 4: Run the Enhanced Installation (Optional)

If you want additional configurations, you can run the enhanced installation script:

```bash
sh scripts/install_enhanced.sh
```

This script includes additional configurations beyond the basic setup. Feel free to run it for more customization options.

### Step 5: Verify Installation

After running the installation script(s), verify that everything is set up correctly by opening Vim, Tmux, or Neovim. If you encounter any issues or have questions, please don't hesitate to report them by opening an issue.
