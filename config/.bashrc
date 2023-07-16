#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Avoid loading ranger config file twice
export RANGER_LOAD_DEFAULT_RC=false

# Start ssh-agent and add identities
eval "$(ssh-agent -s)" > /dev/null
ssh-add &> /dev/null

