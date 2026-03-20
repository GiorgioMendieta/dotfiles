# Raspberry-pi like prompt
PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '

# Cycle through completion matches
bind 'TAB:menu-complete'
bind '"\e[Z": menu-complete-backward'
