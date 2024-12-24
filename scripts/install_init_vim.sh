
# Define source and destination directories
SOURCE_DOTFILES="$HOME/.dotfiles/.config"
DESTINATION_CONFIG="$HOME/.config"

# Files to semi-link
FILES_TO_LINK=("nvim" "wall.png")

# Create symbolic links for specified files
for FILE in "${FILES_TO_LINK[@]}"; do
    SRC="$SOURCE_DOTFILES/$FILE"
    DEST="$DESTINATION_CONFIG/$FILE"

    if [ -e "$DEST" ]; then
        echo "Deleting existing file or directory: $DEST"
        rm -rf "$DEST"
    fi

    if [ -e "$SRC" ]; then
        echo "Creating symbolic link for $FILE"
        ln -s "$SRC" "$DEST"
    else
        echo "Source $SRC does not exist. Skipping."
    fi
done

