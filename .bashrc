# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias l.='ls -d .*'

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# If there are multiple matches for completion, Tab should cycle through them
bind 'TAB:menu-complete'
# And Shift-Tab should cycle backwards
bind '"\e[Z": menu-complete-backward'

alias ..='cd ../'
alias path="echo ${PATH} | tr ':' '\n'"

alias grep="grep --color=auto"
alias hgrep='history | grep'

cd() {
    builtin cd "$@"
    ls
}

ff() {
    find . -path ./.git -prune -o -type f -iname "*${1}*" 2>/dev/null
}


fd() {
    find . -path ./.git -prune -o -type d -iname "*${1}*" 2>/dev/null
}

# History configuration
HISTIGNORE='ls *:l:ll *:tree *:pwd:man *:history'
HISTCONTROL='ignoredups:ignorespace'

# tmux
alias t="tmux attach || tmux new-session"
alias ta="tmux attach -t"
alias tn="tmux new-session"
alias tl="tmux list-sessions"
