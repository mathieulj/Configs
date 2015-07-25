#!/bin/bash

# install file for customization scripts
# can be run with options install and/or uninstall

PWD=$(pwd)
HOME=~
BACKUP=$PWD/uninstall_files
DEPENDS=$'vim-nox\n'
DEPENDS+=$'clang\n'
DEPENDS+=$'vim-youcompleteme\n'
DEPENDS+=$'vim-snippets\n'
DEPENDS+=$'vim-snipmate\n'
DEPENDS+=$'vim-scripts\n'
DEPENDS+=$'vim-addon-manager'

function main(){
if [ $# -ne 1 ]; then
    echo "Error, expects exactly parameter of install or uninstall."
    exit
fi

if [ $1 == "install" ]; then
    install
elif [ $1 == "uninstall" ]; then
    uninstall
else
    echo "Error, unknown parameter $1"
fi
}

function install(){
    echo "Running installation."
    mkdir -p $BACKUP || exit 1;

    echo "Pulling all git submodules."
    git submodule update --init --recursive

    installFile .profile
    installFile .tmux.conf
    installFile .vimrc
    installFile .bash_aliases
    installFile c.vim .vim/syntax/
    installFile cpp.vim .vim/syntax/
    installFile bundle/vim-colors-solarized/colors/solarized.vim .vim/colors/
    installFile bundle/vim-javascript-syntax/syntax/javascript.vim .vim/syntax/
    installFile tmx bin/
    installFile topProcs bin/
    installFile bundle/vim-airline/autoload/airline .vim/autoload/
    installFile bundle/vim-airline/autoload/airline.vim .vim/autoload/
    installFile bundle/vim-airline/plugin/airline.vim .vim/plugin/airline/
    installFile bundle/vim-airline/t .vim/
    
    installDepends
    vim-addon-manager install youcompleteme doxygen-toolkit || exit 1;
    echo
    echo "Action succesfully applied"
}

function uninstall(){
    echo "Running uninstallation"
    uninstallFile .profile
    uninstallFile .tmux.conf
    uninstallFile .vimrc
    uninstallFile .bash_aliases
    uninstallFile c.vim .vim/syntax/
    uninstallFile cpp.vim .vim/syntax/
    uninstallFile bundle/vim-colors-solarized/colors/solarized.vim .vim/colors/
    uninstallFile bundle/vim-javascript-syntax/syntax/javascript.vim .vim/syntax/
    uninstallFile tmx bin/
    uninstallFile topProcs bin/
    uninstallFile bundle/vim-airline/autoload/airline .vim/autoload/
    uninstallFile bundle/vim-airline/autoload/airline.vim .vim/autoload/
    uninstallFile bundle/vim-airline/plugin/airline.vim .vim/plugin/airline/
    uninstallFile bundle/vim-airline/t .vim/
   
    echo
    echo Note that dependecies installed through apt-get and vim-addon-manager are not automatically removed.
    echo
    echo apt-get :
    echo "$DEPENDS"
    echo 
    echo vim-addon-manager :
    echo youcompleteme doxygen-toolkit 
    echo
    echo Action succesfully applied
}

function backupFile(){
    echo "Saving a backup copy of $1"
    mv $1 $BACKUP/$(basename $1) || exit 1;
}

function restoreFile(){
    FN=$BACKUP/$(basename $1) 
    if [ -e $FN ]; then
        echo "Restoring backed up copy of $1"
        mv $FN $1 || exit 1;
    else
        echo "No backed up copy of $1"
    fi
}

function installFile(){
    SRC=$PWD/$1
    DSTDIR=$HOME/$2
    DST=$DSTDIR$(basename $1)
    echo
    echo "Attempting to install file $SRC to $DST"
    # create destination dir if it does not exist
    mkdir -p $DSTDIR || exit 1;     

    if [ -e $DST ]; then
        if [ -h $DST ]; then
            echo "Symlink detected, updating it."
            rm $DST
        else
            echo "File already exists."
            backupFile $DST
        fi
    fi
    ln -s $SRC $DST || exit 1
}

function uninstallFile(){
    SRC=$PWD/$1
    DSTDIR=$HOME/$2
    DST=$DSTDIR$(basename $1)
    echo
    echo "Attempting to uninstall file $SRC from $DST"

    if [ -h $DST ]; then
        echo "Symlink detected, removing it."
        rm $DST
        restoreFile $DST
    elif [ -e $DST ]; then
        echo "Regular file detected, doing nothing."
    else
        restoreFile $DST
    fi
}

function installDepends()
{
    echo 
    echo "Installing missing dependencies, sudo will be needed."

    INSTALLED=$(dpkg --get-selections | grep -v deinstall | cut -f1)

    while read -r line; do
        if [ $(echo $INSTALLED | grep $line | wc -l) -ne 0 ]; then
            echo "$line already installed."
            DEPENDS=$(echo "$DEPENDS" | grep -v $line)
        fi
    done <<< "$DEPENDS"

    if [ -z "$DEPENDS" ]; then
        echo "All libraries are already installed."       
    else
        sudo apt-get install -y $(echo "$DEPENDS" | tr '\n' ' ') || exit 1;
    fi
}

main $@

#ln -s /usr/lib/x86_64-linux-gnu/libclang.so.1 /usr/lib/x86_64-linux-gnu/libclang.so
#sudo apt-get install vim-scripts vim-youcompleteme
#vim-addon-manager install youcompleteme doxygen-toolkit
