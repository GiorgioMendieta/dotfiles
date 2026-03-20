# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias l. ='ls

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# If there are multiple matches for completion, Tab should cycle through them
bind 'TAB:menu-complete'
# And Shift-Tab should cycle backwards
bind '"\e[Z": menu-complete-backward'

alias ..='cd ../'

alias hgrep='history | grep'

# History configuration
HISTIGNORE='ls *:l:ll *:..:tree *:pwd:man *:history'
HISTCONTROL='ignoredups:ignorespace'


