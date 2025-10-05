# Function to create a symlink, creating parent directories if needed
link_dotfile () {
    # Get the target directory
    target_dir=$(dirname "$2")
    # Create target directory chain if it doesn't exist
    mkdir -p "$target_dir"
    # Remove existing file
    rm -f "$2"
    # Create symlink
    ln -sf "$1" "$2"
}
