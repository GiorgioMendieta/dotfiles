#!/bin/bash
source "$DOTFILES/scripts/helper_scripts.sh"

echo ".zshrc config file"
link_dotfile "$DOTFILES/.zshrc" "$HOME/.zshrc"

echo "Setting Mackup config file"
link_dotfile "$DOTFILES/.mackup.cfg" "$HOME/.mackup.cfg"

echo "Setting Karabiner-Elements config file"
link_dotfile "$DOTFILES/Apps/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

echo "Setting Linearmouse config file"
link_dotfile "$DOTFILES/Apps/linearmouse/linearmouse.json" "$HOME/.config/linearmouse/linearmouse.json"

echo "Setting Neofetch config file"
link_dotfile "$DOTFILES/Apps/neofetch/config.conf" "$HOME/.config/neofetch/config.conf"

echo "Setting Vim config files"
link_dotfile "$DOTFILES/Apps/vim/.vimrc" "$HOME/.vimrc"
link_dotfile "$DOTFILES/Apps/vim/.vim" "$HOME/.vim"

echo "Setting Nano config files"
link_dotfile "$DOTFILES/.nanorc" "$HOME/.nanorc"

echo "Setting nvim config file"
link_dotfile "$DOTFILES/Apps/vim/.vimrc" "$HOME/.config/nvim/init.vim"

#echo "Rectangle config file"
#link_dotfile "$DOTFILES/Apps/Rectangle/RectangleConfig.json" "$HOME/Library/Application Support/Rectangle/RectangleConfig.json"

echo "Setting bat theme"
run mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
run bat cache --build

echo "Setting ghostty"
run mkdir -p "$HOME/.config/ghostty/themes"
wget -P "$HOME/.config/ghostty/themes" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-latte.conf
wget -P "$HOME/.config/ghostty/themes" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-frappe.conf
wget -P "$HOME/.config/ghostty/themes" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-macchiato.conf
wget -P "$HOME/.config/ghostty/themes" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-mocha.conf
# Create a symlink to the actual config file to be opened by ghostty (Cmd + ,)
link_dotfile "$DOTFILES/Apps/ghostty/config" "$HOME/.config/ghostty/config"
link_dotfile "$DOTFILES/Apps/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
