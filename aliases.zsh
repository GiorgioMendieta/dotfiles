# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------
alias reloadshell="source $HOME/.zshrc"
alias hxtutor="hx --tutor"

# SSH 
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias sshconfig="code $HOME/.ssh/config"

# Show PATH in readable view (replace : with newline)
alias path='echo ${PATH} | tr ":" "\n"'

# Re-run last command as sudo
alias please='sudo $(fc -ln -1)'

# Show mounted physical drives by column
alias mnt='mount | grep -E ^/dev | column -t'

# Visual Studio Code 
vsc() {
  if [ "$1" != "" ]; then
    # Open file in VSC
    code $1
  else
    # Open current directory in VSC
    code .
  fi
}

# Performance monitoring CLI tool for Apple Silicon
alias asitop='sudo asitop'

# Avoid accidental deletions by enabling interactive mode
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Prevent rm -f from asking for confirmation on things like `rm -f *.bak`.
setopt rm_star_silent

# alias rm='safedelete'
# function safedelete {
#   if command -v gio > /dev/null; then
#     for f in "$@"
#     do
#       gio trash -f "$f"
#     done

#   elif command -v gvfs-trash > /dev/null; then
#     for f in "$@"
#     do
#       gvfs-trash "$f"
#     done

#   elif [ -d "$HOME/.local/share/Trash/files" ]; then
#     for f in "$@"
#     do
#       mv "$f" "$HOME/.local/share/Trash/files"
#     done

#   else
#     for f in "$@"
#     do
#       # shellcheck disable=SC1012
#       \rm "$f"
#     done
#   fi
# }

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------
# Show current IP address
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'
alias myextip='curl -s ipv4.icanhazip.com' # Show external IPv4 address

# Show MAC address (MacOs only)
alias mymac="networksetup -listallhardwareports | grep Wi-Fi -A 3 | grep 'Ethernet Address'"

# Reload DNS
# alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

# ping only 5 times then stop
alias ping='ping -c 5'

# ------------------------------------------------------------------------------
# Python & Virtual Environments
# ------------------------------------------------------------------------------
# Create python virtual environmnet
alias pvenv='python3 -m venv ./venv'
alias pvenv2="virtualenv -p python2 ./venv"
# alias pvenv2="virtualenv -p `which python2.6` ./venv"

# Activate venv
alias avenv='source ./venv/bin/activate'
alias avenv2='source ./venv2/bin/activate'
alias pip2="python2 -m pip"

# ------------------------------------------------------------------------------
# Directory shortcuts
# ------------------------------------------------------------------------------
# Open .dotfiles (this repo)
alias dotfiles="cd $DOTFILES"

# Open custom alias file (this file)
alias calias="code $ZSH_CUSTOM/aliases.zsh"
alias library="cd $HOME/Library"
alias dev="cd $HOME/Developer"
# alias dw="cd $HOME/Downloads && open . && exit"

# Sorbonne Université
alias sorbonne="cd $HOME/Developer/Sorbonne_Universite"
# alias vlsi="cd $HOME/Developer/Sorbonne_Universite/VLSI-TPs"
# alias pscr="cd $HOME/Developer/Sorbonne_Universite/PSCR-TME"
# alias ioc="cd $HOME/Developer/Sorbonne_Universite/IOC-TME"
# alias multi="cd $HOME/Developer/Sorbonne_Universite/MULTI-TPs"
alias mobj="cd $HOME/Developer/Sorbonne_Universite/MOBJ"

# Directory navigation
up (){
  if [[ "$#" < 1 ]]; then
    # Navigate up one level
    cd ..
  else
    # Navigate up multiple levels
    CDSTR=""
    for i in {1..$1}; do
      CDSTR="../$CDSTR"
    done
    cd $CDSTR
  fi
}

# Create dir and immediately cd into it
mkcd() {
  if [ ! -n "$1" ]; then
    echo "Enter a directory name"
  elif [ -d $1 ]; then
    echo "\`$1' already exists"
  else
    mkdir -p $1 && cd $1
  fi
}

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------
# alias gst="git status"
# alias gb="git branch"
# alias gc="git checkout"
# alias gl="git log --oneline --decorate --color"
# alias gl='git log --graph --pretty="%C(red)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%ad) %C(bold blue)<%an>%C(reset)" --date=short'
# alias gl="git log --graph --abbrev-commit --date=format:'%Y-%m-%d' --format=format:'%C(03)%>|(15)%h%C(reset)  %C(04)%ad%C(reset)  %C(green)%<(16,trunc)%an%C(reset)  %C(bold 1)%d%C(reset) %C(bold)%>|(1)%s%C(reset)' --all"
# alias amend="git add . && git commit --amend --no-edit"
# alias commit="git add . && git commit -m"
# alias diff="git diff"
# alias force="git push --force"
# alias nuke="git clean -df && git reset --hard"
# alias pop="git stash pop"
# alias pull="git pull"
# alias push="git push"
# alias resolve="git add . && git commit --no-edit"
# alias stash="git stash -u"
# alias unstage="git restore --staged ."
# alias wip="commit wip"

# ------------------------------------------------------------------------------
# Packages & Apps
# ------------------------------------------------------------------------------
# Update homebrew (hide output) and show outdated formulae
bold=$(tput bold)
normal=$(tput sgr0)
# TODO: Format output using awk & Sort columns
outdated(){
  brew update > /dev/null 2>&1
  echo "${bold}Outdated packages:${normal}"
  brew outdated
  echo "\n${bold}Outdated casks:${normal}"
  brew outdated --casks -g
  echo "\n${bold}Outdated App store apps:${normal}"
  mas outdated
}

# ------------------------------------------------------------------------------
# Useful replacements
# ------------------------------------------------------------------------------

# Replace vim by Neovim
alias vim=nvim

# Bat is a cat clone with syntax highlighting and Git integration
if [ -x "$(command -v bat)" ]; then
    # Replace cat with bat 
    alias cat='bat'

    # Color help pages with bat
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

    # Color defaults read output with bat
    defaultsread() {
        local domain
        domain=$1

        local key
        key=$2

        if [ -z "$key" ]; then
            defaults read "$domain" | bat --language json
        else
            defaults read "$domain" "$key" | bat --language json
        fi
    } 
fi

# eza (Enhanced Zsh Aliases) is a command-line tool that enhances the output of the ls command.
if [ -x "$(command -v eza)" ]; then
  # Display type indicator by file names
  alias ls='eza --classify --icons'

  # Show header, git status, and sort by type
  alias ll='ls -lh --git --sort=extension'

  # Show all files
  alias la='ls -a'

  # Show all files (long)
  alias lla='ll -a'

  # Show only hidden files
  alias l.='ls -d .*'
  alias ll.='ll -d .*'

  # Tree view (long)
  alias llt='ll --tree --level=2'

  # Tree view (level in parameter)
  lt() {
    if [ "$1" != "" ]; then
      eza --tree --icons --level=$1
    else
      eza --tree --icons --level=1
    fi
  }

# Tree view (directories only)
  ltd() {
    if [ "$1" != "" ]; then
      eza --tree --icons -D --level=$1
    else
      eza --tree --icons -D --level=1
    fi
  }
fi

# Set up fzf key bindings and fuzzy completion (useful for searching command history with ctrl + r) 
# ** + tab to search for files
source <(fzf --zsh)

# Show files (ls) after changing directory (cd)
cd ()
{
  builtin cd $1
  ls
}

# ------------------------------------------------------------------------------
# Misc
# ------------------------------------------------------------------------------
man2pdf() {
    # Get the macOS version (e.g. 14.7.1)
    local version
    version=$(sw_vers -productVersion)
    # Extract the major version number (before the first dot)
    local major_version
    major_version=$(echo "$version" | cut -d '.' -f 1)
    
    # Check if the major version is 14 (Ventura) or higher
    if [[ $major_version -ge 14 ]]; then
        # Ventura or higher
        mandoc -T pdf `man -w $@` | open -f -F -n -a /System/Applications/Preview.app
    else
        # Lower than Ventura
        man -t "${1}" | open -f -F -n -a /System/Applications/Preview.app
    fi
}

_calcram() {
    local sum
    sum=0
    for i in `ps aux | grep -i "$1" | grep -v "grep" | awk '{print $6}'`; do
        sum=$(($i + $sum))
    done
    sum=$(echo "scale=2; $sum / 1024.0" | bc)
    echo $sum
}

# Show how much RAM application uses.
# e.g. $ ram safari
# # => safari uses 154.69 MBs of RAM
ram() {
    local sum
    local app="$1"
    if [ -z "$app" ]; then
        echo "First argument - pattern to grep from processes"
        return 0
    fi

    sum=$(_calcram $app)
    if [[ $sum != "0" ]]; then
        echo "${fg[blue]}${app}${reset_color} uses ${fg[green]}${sum}${reset_color} MBs of RAM"
    else
        echo "No active processes matching pattern '${fg[blue]}${app}${reset_color}'"
    fi
}

alias :q='echo You are not editing a file, dummy.'
alias :wq='echo You are not editing a file, dummy.'

alias copyclang-format="cp $DOTFILES/.clang-format ./" # Copy clang-format file to current directory

applyclangformat() {
    echo "Applying clang-format to all .cpp and .h files in the current directory..."

    if [ -f .clang-format ]; then
    echo "Found .clang-format file in the current directory"
    else
    echo "No .clang-format file found in the current directory"
    echo "Copying .clang-format file from $DOTFILES to the current directory..."
    copyclang-format
    fi

    find . -iname "*.cpp" -o -iname "*.h" | xargs clang-format -i --style=file --fallback-style=none

    echo "Done!"
}

# ------------------------------------------------------------------------------
# Raspberry pi aliases
# ------------------------------------------------------------------------------

# alias mountusb='sudo mount /dev/sda1 /mnt/usb'
# alias unmountusb='sudo umount /mnt/usb'
# # List files in a human readable format
# alias ll='ls -alF'
# alias bashrc="nano ~/.bashrc " # edit bashrc