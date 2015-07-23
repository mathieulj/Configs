alias tmux="tmux -2"

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ "$TERM" == "xterm" ]; then
    if [ -e /usr/share/terminfo/x/xterm+256color ]; then
        export TERM='xterm+256color'
    elif [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
    else
        export TERM='xterm-color'
    fi
fi
