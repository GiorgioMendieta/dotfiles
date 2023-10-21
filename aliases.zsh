# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="source $HOME/.zshrc"
# alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
# alias ll="/opt/homebrew/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
# alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
# alias compile="commit 'compile'"
# alias version="commit 'version'"

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
alias developer="cd $HOME/Developer"

# Git
# alias gst="git status"
# alias gb="git branch"
# alias gc="git checkout"
# alias gl="git log --oneline --decorate --color"
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

# Homebrew
alias outdated="brew update; brew outdated"

bric() {
  brew install --cask $1
}

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
	if [ "$1" != "" ]
    		then
        		exa --tree --icons --level=$1
    		else
        		exa --tree --icons --level=1
    		fi
    }
fi

# Navigation aliases
# alias up='cd ..'
function up {
        if [[ "$#" < 1 ]] ; then
            # Navigate up one level
            cd ..
        else
            # Navigate up multiple levels
            CDSTR=""
            for i in {1..$1} ; do
                CDSTR="../$CDSTR"
            done
            cd $CDSTR
        fi
    }

alias please='sudo $(fc -ln -1)'

alias vim=nvim

# open a man page as a pdf
manpdf() {
  man -t "${1}" | open -f -a Preview.app
}

# Create python virtual environmnet
alias pvenv='python3 -m venv ./venv'
# Activate venv
alias avenv='source ./venv/bin/activate'

# Path to custom alias file (this file)
alias calias='code ~/.oh-my-zsh/custom/aliases.zsh'

# Show mounted physical drives by column
alias mnt='mount | grep -E ^/dev | column -t'