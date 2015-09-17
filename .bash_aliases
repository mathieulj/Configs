alias tmux="tmux -2"
export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w (\$(git rev-parse --abbrev-ref HEAD 2>/dev/null)) \$ "

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

if [ "$TERM" == "xterm" ]; then
    export TERM='xterm-256color'
fi
##    if [ -e /usr/share/terminfo/x/xterm+256color ]; then
##        export TERM='xterm+256color'
##    elif [ -e /usr/share/terminfo/x/xterm-256color ]; then
##        export TERM='xterm-256color'
##    else
##        export TERM='xterm-color'
##    fi
##fi
