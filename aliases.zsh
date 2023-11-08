# ------------------------------------------------------------------------------
# Shortcuts
# ------------------------------------------------------------------------------
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="source $HOME/.zshrc"
# Show PATH in readable view
alias path='echo "${PATH//:/\\n}"'
# Show current IP address
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'
# Reload DNS
# alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
# Re-run last command as sudo
alias please='sudo $(fc -ln -1)'
# Create python virtual environmnet
alias pvenv='python3 -m venv ./venv'
# Activate venv
alias avenv='source ./venv/bin/activate'
# Show mounted physical drives by column
alias mnt='mount | grep -E ^/dev | column -t'

# ------------------------------------------------------------------------------
# Directories shortcuts
# ------------------------------------------------------------------------------
# Open .dotfiles (this repo)
alias dotfiles="cd $DOTFILES && ls"
# Open custom alias file (this file)
alias calias="code $ZSH_CUSTOM/aliases.zsh"
alias library="cd $HOME/Library && ls"
alias developer="cd $HOME/Developer && ls"

# Sorbonne Université
alias sorbonne="cd $HOME/Developer/Sorbonne\ Universite && ls"
alias vlsi="cd $HOME/Developer/Sorbonne\ Universite/VLSI-TPs && ls"
alias pscr="cd $HOME/Developer/Sorbonne\ Universite/PSCR-TME && ls"
alias algav="cd $HOME/Developer/Sorbonne\ Universite/ALGAV-projet && ls"

# Directory navigation
function up {
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
function mkcd {
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
# TODO: Format output using awk
# TODO: Sort columns
outdated(){
  brew update > /dev/null 2>&1
  echo "${bold}Outdated packages:\n${normal}"
  brew outdated
  echo "\n${bold}Outdated casks:\n${normal}"
  brew outdated --casks -g
  echo "\n${bold}Outdated App store apps:\n${normal}"
  mas outdated
}

# Install Homebrew cask
bric() {
  brew install --cask $1
}
# Install Homebrew formula
bri() {
  brew install $1
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
# Useful replacements
# ------------------------------------------------------------------------------

# Replace vim by Neovim
alias vim=nvim

# Replace cat with bat 
alias cat='bat'

# Color help pages with bat
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# exa aliases
if [ -x "$(command -v exa)" ]; then
  # Display type indicator by file names
  alias ls='exa --classify --icons'

  # Show header, git status, and sort by type
  alias ll='ls -lh --git --sort type'

  # Show hidden files
  alias la='ls -a'

  # Show hidden files (long)
  alias lla='ll -a'

  # Tree view (long)
  alias llt='ll --tree --level=2'

  # Tree view (level in parameter)
  function lt {
    if [ "$1" != "" ]; then
      exa --tree --icons --level=$1
    else
      exa --tree --icons --level=1
    fi
  }
fi

# ------------------------------------------------------------------------------
# Misc
# ------------------------------------------------------------------------------

# open a man page as a pdf (DEPRECATED SINCE VENTURA)
manpdf() {
  man -t "${1}" | open -f -a Preview.app
}