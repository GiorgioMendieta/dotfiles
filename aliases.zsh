# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------
# Quick config shortcuts
alias zshconfig="vim $HOME/.zshrc; omz reload"
alias aliasconfig="vim $DOTFILES/aliases.zsh; omz reload" 
alias vimconfig="vim $DOTFILES/Apps/vim/.vimrc"
alias sshconfig="vim $HOME/.ssh/config"
# alias reloadshell="source $HOME/.zshrc"
alias rsh="omz reload"

# Search aliases using fzf
alias salias="alias | fzf"

alias hgrep="history | grep"

# SSH
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"

# Re-run last command as sudo
alias please='sudo $(fc -ln -1)'

# Show mounted physical drives by column
alias mnt='mount | grep -E ^/dev | column -t'

# Visual Studio Code
alias vsc="code ."

# Performance monitoring CLI tool for Apple Silicon
alias mactop='sudo mactop'

# Avoid accidental deletions by enabling interactive mode
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Prevent rm -f from asking for confirmation on things like `rm -f *.bak`.
setopt rm_star_silent

# List users formatted as a table
alias lsusers='cat /etc/passwd | column -t -s ":" -N USERNAME,PW,UID,GUID,COMMENT,HOME,INTERPRETER'

# ------------------------------------------------------------------------------
# Networking
# ------------------------------------------------------------------------------
# Show current IP address
if [[ "$(uname -s)" == "Linux" ]]; then
  alias myip='hostname -I'
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'
fi

alias myextip='curl -s ipv4.icanhazip.com' # Show external IPv4 address

# Show MAC address (MacOs only)
alias mymac="networksetup -listallhardwareports | grep Wi-Fi -A 3 | grep 'Ethernet Address'"

# Reload DNS
# alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

# ping only 5 times then stop
# alias ping='ping -c 5'

# ------------------------------------------------------------------------------
# Python & Virtual Environments
# ------------------------------------------------------------------------------
# Create python virtual environmnet
alias venv='python3 -m venv ./.venv'
alias venv2="virtualenv -p python2 ./.venv"

# Activate venv
alias avenv='source ./.venv/bin/activate'
alias avenv2='source ./.venv2/bin/activate'
alias pip2="python2 -m pip"

#Additional kernels can be installed into the shared jupyter directory
#  /opt/homebrew/etc/jupyter
#
#To start jupyterlab now and restart at login:
#  brew services start jupyterlab
#Or, if you don't want/need a background service you can just run:
# /opt/homebrew/opt/jupyterlab/bin/jupyter-lab
# alias jupyter=/opt/homebrew/opt/jupyterlab/bin/jupyter-lab

# ------------------------------------------------------------------------------
# Directory shortcuts
# ------------------------------------------------------------------------------
# Open .dotfiles (this repo)
alias dot="cd $DOTFILES"
alias library="cd $HOME/Library"
alias dev="cd $HOME/Developer"
alias lab="cd $HOME/docker"

# Sorbonne Université
alias sorbonne="cd $HOME/Developer/Sorbonne_Universite"
alias smc="cd $HOME/Developer/Sorbonne_Universite/SMC-TPs"
alias icloud="cd $HOME/Library/Mobile\ Documents/com~apple~CloudDocs"

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
# Path 
# ------------------------------------------------------------------------------

# Show PATH in readable view (Replace or (tr)anslate ':' with '\n')
alias path='echo ${PATH} | tr ":" "\n"'
# Add personal scripts to path
add_to_path "${DOTFILES}/bin"

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

# Homebrew
alias bri="brew install"
alias bric="brew install --cask"
alias brewgraph="brew deps --installed --graph"

## Apt
alias sai="sudo apt install"

if [[ "$(uname -s)" == "Linux" ]]; then
  alias outdated="sudo apt update >/dev/null 2>&1; apt list --upgradeable | tail -n +2 | awk '{print \$1, \$6, \$2}' | tr -d ']' | column -t -N 'PACKAGE NAME','OLD VERSION','NEW VERSION'"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  alias outdated='brew update >/dev/null 2>&1; brew outdated'
fi

# ------------------------------------------------------------------------------
# Useful replacements
# ------------------------------------------------------------------------------
# Quickly calculate SHA256 hash of a file
alias sha256="shasum -a 256"
# Replace vim by Neovim
alias vim="nvim"

# Bat is a cat clone with syntax highlighting and Git integration
# Ubuntu compatibility
if [[ "$(uname -s)" == "Linux" ]]; then
    export MANPAGER=less
fi


if [ -x "$(command -v bat)" ]; then
    # Replace cat with bat
    alias cat='bat'

    # TODO: Fix error (https://github.com/ohmyzsh/ohmyzsh/issues/12457)
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


if [ -x "$(command -v fzf)" ]; then
	# fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"
fi
# Set up fzf key bindings and fuzzy completion (useful for searching command history with ctrl + r)
# ** + tab to search for files
source <(fzf --zsh)

# Show files (ls) after changing directory (cd)
cd() {
    builtin cd "$@"
    echo ""
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
        mandoc -T pdf $(man -w $@) | open -f -F -n -a /System/Applications/Preview.app
    else
        # Lower than Ventura
        man -t "${1}" | open -f -F -n -a /System/Applications/Preview.app
    fi
}

alias :q="exit"
alias :wq="exit"

alias copyclang-format="cp $DOTFILES/.clang-format ./" # Copy clang-format file to current directory

applyclangformat() {

    if [ -f .clang-format ]; then
        echo "Found .clang-format file in the current directory!"
    else
        echo "No .clang-format file found in the current directory"
        echo "Copying .clang-format file from $DOTFILES to the current directory..."
        copyclang-format
    fi

    echo "Applying clang-format to all .cpp and .h files in the current directory..."

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



# ------------------------------------------------------------------------------
# Docker aliases
# ------------------------------------------------------------------------------
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}"'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
