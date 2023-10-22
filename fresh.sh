#!/bin/sh

echo "Setting up your Mac..."

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  echo "Installing Oh My Zsh..."
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  echo "Installing Homebrew" 
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s .zshrc $HOME/.zshrc

# Install Powerlevel10k theme on the ZSH_CUSTOM path, else to the default path
echo "Installing Powerlevel 10k theme..."
sudo rm -R ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Removes .p10k.zsh from $HOME (if it exists) and symlinks the .p10k.zsh file from the .dotfiles
rm -rf $HOME/.p10k.zsh
ln -s .p10k.zsh $HOME/.p10k.zsh

# Meslo Nerd Font (recommended by the creator of Powerlevel10k theme)
echo "Installing Meslo Nerd Font"
# Select fonts folder path
FONTS_FOLDER_PATH=$HOME/Library/Fonts
# Make sure that the fonts directory exists
mkdir -p ${FONTS_FOLDER_PATH}

# Download fonts
(curl -Lo "${FONTS_FOLDER_PATH}/MesloLGS NF Regular.ttf"     "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf")       &> /dev/null
(curl -Lo "${FONTS_FOLDER_PATH}/MesloLGS NF Bold.ttf"        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf")          &> /dev/null
(curl -Lo "${FONTS_FOLDER_PATH}/MesloLGS NF Italic.ttf"      "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf")        &> /dev/null
(curl -Lo "${FONTS_FOLDER_PATH}/MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf") &> /dev/null

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
echo "Installing Homebrew dependencies" 
brew tap homebrew/bundle
brew bundle --file ./Brewfile

# Set default MySQL root password and auth type
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Create a projects directories
mkdir $HOME/Developer
# mkdir $HOME/Code
# mkdir $HOME/Herd

# Create Code subdirectories
# mkdir $HOME/Code/blade-ui-kit
# mkdir $HOME/Code/laravel

# Clone Github repositories
# ./clone.sh

# Symlink the Mackup config file to the home directory
ln -s ./.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos