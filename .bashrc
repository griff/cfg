# .bashrc
# Author: Brian Olsen <brian@maven-group.org>
# Source: http://github.com/griff/cfg/.bashrc

if [ -n "$TERM" -a "$TERM" != "dumb" ]; then

#Global options {{{
export HISTFILESIZE=999999
export HISTSIZE=999999
export HISTCONTROL=ignoredups:ignorespace
export EMAIL=brian@maven-group.org
export FTP_PASSIVE=1
shopt -s histappend
shopt -s checkwinsize
shopt -s progcomp

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -d "$HOME/.nix-profile/etc" ]; then
  if [ -d "$HOME/.nix-profile/etc/profile.d" ]; then
    for k in $HOME/.nix-profile/etc/profile.d/* ; do
      . "$k"
    done
  fi
  if [ -d "$HOME/.nix-profile/etc/bash_completion.d" ]; then
    for k in $HOME/.nix-profile/etc/bash_completion.d/* ; do
      . "$k"
    done
  fi
elif [ -d "/nix/var/nix/profiles/default/etc" ]; then
  if [ -d "/nix/var/nix/profiles/default/etc/profile.d" ]; then
    for k in /nix/var/nix/profiles/default/etc/profile.d/* ; do
      . "$k"
    done
  fi
  if [ -d "/nix/var/nix/profiles/default/etc/bash_completion.d" ]; then
    for k in /nix/var/nix/profiles/default/etc/bash_completion.d/* ; do
      . "$k"
    done
  fi
fi

#path should have durdn config bin folder
export PATH=$HOME/.cfg/bin:$PATH
#set the terminal type to 256 colors
export TERM=xterm-256color

if [ $(uname) == "Darwin" ]; then
  #export PATH=/usr/local/mysql/bin:$HOME/bin:/opt/local/sbin:/opt/local/bin:$PATH
  #export PATH=/Users/nick/.clj/bin:$PATH
  export PATH=$HOME/.cfg/bin/Darwin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$PATH
fi

# }}}

if [[ $- = *i* ]]; then
  . $HOME/.cfg/liquidprompt/liquidprompt
fi
for k in $HOME/.cfg/lib/*.sh; do
  . $k
done

#Global aliases  {{{
alias g='git'
alias gs='git status'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gi='git di'
alias gl='git log'
alias gp='git push'
alias gf='git fetch'
alias gm='git m'
#alias go='git checkout '
alias vimo='vim -O'
alias laste='tail -1000 ~/.bash_history | grep ^vim | col 2'
alias drun="docker run"
alias dps="docker ps"
alias dimg="docker images"
alias dbuild="docker build"
alias dlog="docker log"

run_gpgconf() {
  if [[ -e "/usr/local/MacGPG2/bin/gpgconf" ]]; then
    /usr/local/MacGPG2/bin/gpgconf "$@"
  else
    gpgconf "$@"
  fi
}

if [ -f "$HOME/.gnupg/gpg-agent.conf" ]; then
  export SSH_AUTH_SOCK="$(run_gpgconf --list-dir agent-ssh-socket)"
  if [ ! -S "$SSH_AUTH_SOCK" ]; then
    run_gpgconf --launch gpg-agent
  fi
  GPG_TTY=$(tty)
  export GPG_TTY
fi

if [ -n "$(command -v atom)" ]; then
  export EDITOR=watom
elif [ -n "$(command -v subl)" ]; then
  export EDITOR=wsubl
elif [ -n "$(command -v vim)" ]; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

# Linux specific config {{{
if [ $(uname) == "Linux" ]; then
  shopt -s autocd
  [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

  # enable color support of ls and also add handy aliases
  if [ -x /usr/bin/dircolors ]; then
      test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
      alias ls='ls --color=auto'
      alias grep='grep --color=auto'
      alias fgrep='fgrep --color=auto'
      alias egrep='egrep --color=auto'
  fi

  #alias assumed="git ls-files -v | grep ^[a-z] | sed -e 's/^h\ //'"
  alias assumed="git ls-files -v | grep ^h | sed -e 's/^h\ //'"
  # Add an "alert" alias for long running commands.  Use like so: sleep 10; alert

  #apt aliases
  alias apt='sudo apt-get'
  alias cs='sudo apt-cache search'
  alias pacman='sudo pacman'
  alias pac='sudo pacman'

  alias ls='ls --color'
  alias ll='ls -l --color'
  alias la='ls -al --color'
  alias less='less -R'
  alias psu="ps -HfU $USER"

  if [ -d $HOME/.rbenv ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)";
  fi

  #PATH=$PATH:$HOME/dev/apps/node/bin
fi


# }}}
# OSX specific config {{{
if [ $(uname) == "Darwin" ]; then
  export MANPATH=/usr/local/man:/opt/local/share/man:$MANPATH
  export DYLD_FALLBACK_LIBRARY_PATH=$HOME/lib:/usr/local/lib:/lib:/usr/lib:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/

  #aliases
  alias ls='ls -G'
  alias ll='ls -lG'
  alias la='ls -alG'
  alias less='less -R'
  alias fnd='open -a Finder'
  alias gitx='open -a GitX'
  alias grp='grep -RIi'
  alias assumed="git ls-files -v | grep ^[a-z] | sed -e 's/^h\ //'"

  #setup maven
  if [ -d "$HOME/.m2/versions/Current" ]; then
    export MAVEN_HOME="$HOME/.m2/versions/Current"
    export PATH=$MAVEN_HOME/bin:$PATH
  else
    echo "No maven..."
  fi

  #setup rbenv
  if command -v rbenv > /dev/null; then
    eval "$(rbenv init -)";
    export PATH="$HOME/.rbenv/bin:$PATH"
  fi

  #homebrew autocompletions
  if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
  fi

  #Java home setting
  export JAVA_HOME=$(/usr/libexec/java_home)

  # Vagrant settings
  export VAGRANT_VMWARE_CLONE_DIRECTORY=~/.vagrant_clone
  #export VAGRANT_DEFAULT_PROVIDER=vmware_fusion

  # docker setting
  #export DOCKER_HOST=tcp://localhost:4243

fi

# }}}
# MINGW32_NT-5.1 (winxp) specific config {{{
if [ $(uname) == "MINGW32_NT-5.1" ]; then
  alias ls='ls --color'
  alias ll='ls -l --color'
  alias la='ls -al --color'
  alias less='less -R'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
# }}}

# Autocomplete for aliases
wrap_aliases

export PATH="./vendor/bin:$PATH"

#complete -c .

#__rvm_ps1 ()
# {
#  [[ -n "`which rbenv`" ]] && rbenv version-name
#  echo ""
#}

#GIT_PS1_SHOWUPSTREAM="auto"
#GIT_PS1_SHOWUNTRACKEDFILES="yes"
#GIT_PS1_SHOWDIRTYSTATE="yes"

#case "$TERM" in
#xterm-color|xterm-debian|xterm-*color|screen*)
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\] $(__rvm_ps1)$(__git_ps1 " (%s)")\nλ '
#    ;;
#*)
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W $(__rvm_ps1)$(__git_ps1 " (%s)")\nλ '
#    ;;
#esac
#PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '

export GOPATH=$HOME/gopath
export PATH="$PATH:$GOPATH/bin"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if [ -f "$HOME/.rancher.sh" ]; then
  . "$HOME/.rancher.sh"
fi

if [ -f "$HOME/.drone.sh" ]; then
  . "$HOME/.drone.sh"
fi

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export UMPLOY_KEY="$HOME/.cfg/umploy.key"

export PATH="$HOME/.cargo/bin:$PATH"

# Update prompt title so that Timing gets updated correctly
PROMPT_TITLE='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
export PROMPT_COMMAND="${PROMPT_TITLE}; ${PROMPT_COMMAND}"

# Make sure the history is updated at every command
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

dur check
fi # End of dump terminal check
