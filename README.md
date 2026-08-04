# Dotfiles: Configuration Files for Vim, Tmux, and Git

This repository is my personal Configurations file and also comes with an .sh installer. Feel free to configure and personalize the file to suit your preference.

This is the basic sample that you can copy and use. Tips to improve and make it more personalized will be appreciated.

Instructions on how to install, use, and personalize will be provided below.

## Contents

1. vimrc
2. Tmuxrc
3. gitconfig.sh
4. install.sh
5. Java Snippets (in .config/nvim/lua/snippets/java.lua)

### Installation

To install and use the configuration provided in this repository, follow these steps:


1. firstly you need to use root use
cd    ```bash
       sudo -i

2. Clone the repository to your local machine using the following command:

    ```bash
    git clone https://github.com/Roberamelaek/dotfile.git
    
3. Rename the dotfile to .dotfile:

    ```bash
    mv dotfile .dotfiles
    
4. Change into the repository directory:
    
    ```bash
    cd .dotfiles
    
5. Run the configuration script to install the Vim settings:
    ```bash
    bash install.sh
    
- The files will be copied to your home directory (`~/`) and Vim will be configured accordingly.
- Now you're all set to use the customized Vim configuration!
- Feel free to customize the files before you run <code>sh install.sh</code> have fun with the project and leave feadback for more if you have any questions or helpful and fun ideas!!

## Java Snippets Documentation

Enhanced Java snippets have been added to make creating classes easier and to document coding questions.

### Available Snippets

1. `main` - Creates a basic Main class with main method
2. `class` - Creates a basic class structure
3. `question` - Creates a class with Javadoc comment for documenting a coding question
4. `mainquestion` - Creates a class with main method and Javadoc comment for documenting a coding question

### Usage

To use these snippets in Neovim with LuaSnip:

1. Open a Java file in Neovim
2. Type the snippet trigger (e.g., `question`) 
3. Press `<Tab>` to expand the snippet
4. Use `<Tab>` to navigate between insert points

### Example: Documenting a Coding Question

When creating a new Java class to solve a coding problem:

1. Type `question` and press `<Tab>`
2. Enter the question description at the first insert point
3. Enter the class name at the second insert point
4. Implement your solution in the class body

This approach ensures each class is self-documenting with the coding question it solves, making it easier to understand the purpose of each class in your project.

