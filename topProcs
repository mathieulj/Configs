#!/bin/bash

# run top twice so stats will be fresh
TOPS=$( 
    top -bn2 | 
    tail -n+15 | 
    sed 1,/.*%CPU.*/d | 
    head -n4 |
    sed 's/  [ ]*/ /g' |
    sed 's/^[ ]*//'
)

PIDS=$( 
    echo "$TOPS" | 
    sed 's/^[ ]*\([0-9]*\)[^0-9].*/\1/'
)


while read -r pid; do
    CPU=$(echo "$TOPS" | grep "^$pid " | cut -d' ' -f9 )
    RAM=$(echo "$TOPS" | grep "^$pid " | cut -d' ' -f10 )
    EXE=$(readlink -f "/proc/$pid/exe")
    CWD=$(readlink -f "/proc/$pid/cwd")
    CMD=$(cat "/proc/$pid/cmdline" | sed 's/\x0/ /g')
    
    echo -e "PID $pid"
    echo -e " |       CPU $CPU"
    echo -e " |       RAM $RAM"
    echo -e " | Directory $CWD"
    echo -e " |   Command $CMD"
    echo -e " \---------------"
    echo
done <<< "$PIDS"
