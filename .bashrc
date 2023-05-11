# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export EDITOR="/usr/bin/vim"
PATH="$HOME/.local/bin:${PATH}"

# for iterm
export BASH_SILENCE_DEPRECATION_WARNING=1


# -- History

# ignoreboth ignores commands starting with a space and duplicates. Erasedups
# removes all previous dups in history
export HISTCONTROL=ignoreboth:erasedups  
export HISTFILE=~/.bash_history          # be explicit about file path
export HISTSIZE=100000                   # in memory history size
export HISTFILESIZE=100000               # on disk history size
export HISTTIMEFORMAT='%F %T '
shopt -s histappend # append to history, don't overwrite it
shopt -s cmdhist    # save multi line commands as one command

# Save multi-line commands to the history with embedded newlines
# instead of semicolons -- requries cmdhist to be on.
shopt -s lithist

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# Colored man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'


# # enable GIT prompt options
# export GIT_PS1_SHOWCOLORHINTS=true
# export GIT_PS1_SHOWDIRTYSTATE=true
# export GIT_PS1_SHOWUNTRACKEDFILES=true

#. ~/.bashrc_agent

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=


# # -- Misc

# check windows size if windows is resized
shopt -s checkwinsize

# autocorrect directory if mispelled
shopt -s dirspell direxpand

# # auto cd if only the directory name is given
# shopt -s autocd

# #use extra globing features. See man bash, search extglob.
# shopt -s extglob

# #include .files when globbing.
# shopt -s dotglob

# # Do not exit an interactive shell upon reading EOF.
# set -o ignoreeof;

# # Check the hash table for a command name before searching $PATH.
# shopt -s checkhash

# # Enable `**` pattern in filename expansion to match all files,
# # directories and subdirectories.
# shopt -s globstar

# Do not attempt completions on an empty line.
shopt -s no_empty_cmd_completion

# note: bind used instead of sticking these in .inputrc
bind "set completion-ignore-case on" 

# # Case-insensitive filename matching in filename expansion.
# shopt -s nocaseglob



# Command that Bash executes just before displaying a prompt
export PROMPT_COMMAND=set_prompt

set_prompt() {
  # Capture exit code of last command
  local ex=$?

  # Set prompt content
  PS1="\u@\h:\w$\[$reset\] "
  # If exit code of last command is non-zero, prepend this code to the prompt
  [[ "$ex" -ne 0 ]] && PS1="$PS1($ex) "
  history -a; history -c; history -r
}

#sudo /home/viorel/work/volumeButton.reset.sh


# Source other files

# Senstive functions which are not pushed to Github
# It contains GOPATH, some functions, aliases etc...
[ -r ~/.bash_private ] && source ~/.bash_private

[ -r ~/.bash_aliases ] && source ~/.bash_aliases
[ -r ~/.bash_functions ] && source ~/.bash_functions
[ -r ~/.bash_envs ] && source ~/.bash_envs



# Get it from the original Git repo: 
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
if [ -f ~/.git-prompt.sh ]; then
  source ~/.git-prompt.sh
fi

# # Get it from the original Git repo: 
# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

