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
mkdir -p "$(bat --config-dir)/themes"
curl -fsSL -o "$(bat --config-dir)/themes/catppuccin_latte.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
curl -fsSL -o "$(bat --config-dir)/themes/catppuccin_frappe.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
curl -fsSL -o "$(bat --config-dir)/themes/catppuccin_macchiato.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
curl -fsSL -o "$(bat --config-dir)/themes/catppuccin_mocha.tmTheme" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
link_dotfile "$DOTFILES/Apps/bat/config" "$(bat --config-file)"
run bat cache --build


echo "Setting btop theme"
mkdir -p "$HOME/.config/btop/themes"
curl -fsSL -o "$HOME/.config/btop/themes/catppuccin_latte.theme" https://github.com/catppuccin/btop/raw/main/themes/catppuccin_latte.theme
curl -fsSL -o "$HOME/.config/btop/themes/catppuccin_frappe.theme" https://github.com/catppuccin/btop/raw/main/themes/catppuccin_frappe.theme
curl -fsSL -o "$HOME/.config/btop/themes/catppuccin_macchiato.theme" https://github.com/catppuccin/btop/raw/main/themes/catppuccin_macchiato.theme
curl -fsSL -o "$HOME/.config/btop/themes/catppuccin_mocha.theme" https://github.com/catppuccin/btop/raw/main/themes/catppuccin_mocha.theme
link_dotfile "$DOTFILES/Apps/btop/btop.conf" "$HOME/.config/btop/btop.conf"

echo "Setting ghostty"
mkdir -p "$HOME/.config/ghostty/themes"
curl -fsSL -o "$HOME/.config/ghostty/themes/catppuccin_latte.conf" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-latte.conf
curl -fsSL -o "$HOME/.config/ghostty/themes/catppuccin_frappe.conf" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-frappe.conf
curl -fsSL -o "$HOME/.config/ghostty/themes/catppuccin_macchiato.conf" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-macchiato.conf
curl -fsSL -o "$HOME/.config/ghostty/themes/catppuccin_mocha.conf" https://github.com/catppuccin/ghostty/raw/main/themes/catppuccin-mocha.conf
# Create a symlink to the actual config file to be opened by ghostty (Cmd + ,)
link_dotfile "$DOTFILES/Apps/ghostty/config" "$HOME/.config/ghostty/config"
link_dotfile "$DOTFILES/Apps/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
