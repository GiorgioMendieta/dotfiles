# Function to create a symlink, creating parent directories if needed
link_dotfile() {
    local source="$1"
    local target="$2"
    local target_dir
    local backup

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        printf 'Dotfile source does not exist: %s\n' "$source" >&2
        return 1
    fi

    target_dir=$(dirname "$target") || return
    # Create target directory chain if it doesn't exist
    mkdir -p "$target_dir" || return

    # Check if the target is already a symlink to the source
    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        return 0
    fi

    # If the target exists (either as a file or symlink), create a backup
    if [[ -e "$target" || -L "$target" ]]; then
        backup="${target}.backup.$(date +%Y%m%d%H%M%S).$$"
        if [[ -e "$backup" || -L "$backup" ]]; then
            printf 'Backup destination already exists: %s\n' "$backup" >&2
            return 1
        fi
        mv "$target" "$backup" || return
        printf 'Moved existing file to %s\n' "$backup"
    fi

    # Create symlink
    ln -s "$source" "$target"
}
