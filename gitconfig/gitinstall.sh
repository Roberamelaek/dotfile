#!/bin/bash

# Set up global alias shortcuts for Git configurations
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.hist 'log --oneline --decorate --graph'

echo "Global Git alias shortcuts have been added!"

