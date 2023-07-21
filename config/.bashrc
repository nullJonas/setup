#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

# FIX THIS
#PS1='\e[1;33m[\u@\h \W]\$\e[m '

# Avoid loading ranger config file twice
export RANGER_LOAD_DEFAULT_RC=false

# Start ssh-agent and add identities
eval "$(ssh-agent -s)" > /dev/null
ssh-add &> /dev/null

