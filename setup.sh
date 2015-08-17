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
DEPENDS+=$'fonts-powerline\n'
#DEPENDS+=$'powerline\n'
DEPENDS+=$'vim-pathogen\n'
DEPENDS+=$'vim-addon-manager'
SUDO='su -c'

function main(){
if [ $# -ne 1 ]; then
    echo "Error, expects exactly parameter of install or uninstall."
    exit
fi

if [ $1 == "install" ]; then
    install
elif [ $1 == "uninstall" ]; then
    uninstall
elif [ $1 == "test" ]; then
    installBundle vim-airline
else
    echo "Error, unknown parameter $1"
fi
}

function install(){
    echo "Running installation."
    mkdir -p $BACKUP || exit 1;
    
    echo "Installing dependecies."
    installDepends
    vim-addon-manager install youcompleteme doxygen-toolkit pathogen || exit 1;

    echo "Pulling all git submodules."
    git submodule update --init --recursive || exit 1;

    echo "Installing individual files."
    installFile .profile
    installFile .tmux.conf
    installFile .vimrc
    installFile .bash_aliases
    installFile syntax/c.vim .vim/syntax/
    installFile syntax/cpp.vim .vim/syntax/
    installFile syntax/javascript.vim .vim/syntax/
    installFile tmx bin/
    installFile topProcs bin/
    
    echo "Installing powerline font support."
    installFile bundle/powerline/font/PowerlineSymbols.otf .fonts/
    installFile bundle/powerline/font/10-powerline-symbols.conf .config/fontconfig/conf.d/
    
    echo "Installing vim bundles."
    installBundle vim-javascript-syntax
    installBundle vim-colors-solarized
    installBundle vim-airline
    installBundle vim-fugitive
    installBundle nerdtree
    installBundle nerdtree-git-plugin

    echo "Updating font cache."
    eval "$SUDO \"fc-cache -vf ~/.fonts\"" || exit 1;

    echo
    echo "Action succesfully applied"
}

function uninstall(){
    echo "Running uninstallation"
    
    echo "Uninstalling individual files."
    uninstallFile .profile
    uninstallFile .tmux.conf
    uninstallFile .vimrc
    uninstallFile .bash_aliases
    uninstallFile syntax/c.vim .vim/syntax/
    uninstallFile syntax/cpp.vim .vim/syntax/
    uninstallFile syntax/javascript.vim .vim/syntax/
    uninstallFile tmx bin/
    uninstallFile topProcs bin/

    echo "Uninstalling powerline font support."
    uninstallFile bundle/powerline/font/PowerlineSymbols.otf .fonts/
    uninstallFile bundle/powerline/font/10-powerline-symbols.conf .config/fontconfig/conf.d/

    echo "Uninstalling vim bundles."
    uninstallBundle vim-javascript-syntax
    uninstallBundle vim-colors-solarized
    uninstallBundle vim-airline
    uninstallBundle vim-fugitive
    uninstallBundle nerdtree
    uninstallBundle nerdtree-git-plugin

    echo "Updating font cache."
    eval "$SUDO \"fc-cache -vf ~/.fonts\"" || exit 1;
   
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
    echo "Attempting to install file \"$SRC\" to \"$DST\""

    # create destination dir if it does not exist
    mkdir -p $DSTDIR || exit 1;     

    if [ ! -e $SRC ]; then 
        echo "Error, \"$SRC\" does not exist, upstream may have changed something."
        exit 1;
    fi

    if [ -h $DST ]; then
        echo "Symlink detected, updating it."
        rm $DST || exit 1;
    elif [ -e $DST ]; then
        echo "File already exists."
        backupFile $DST
    fi
    
    ln -s $SRC $DST || exit 1
}

function installBundle(){
    SRC=$PWD/bundle/$1
    DSTDIR=$HOME/.vim/bundle
    DST=$DSTDIR/$1
    echo 
    echo "Installing bundle $1."

    mkdir -p $DSTDIR || exit 1;

    if [ -h $DST ]; then
        echo "Symlink detected, updating it."
        rm $DST || exit 1;
    elif [ -e $DST ]; then
        echo "Error, regular file with same name detected in bundle directory."
        exit 1;
    fi

    ln -s $SRC $DST || exit 1
}

function uninstallBundle(){
    SRC=$PWD/bundle/$1
    DSTDIR=$HOME/.vim/bundle
    DST=$DSTDIR/$1
    echo 
    echo "Uninstalling bundle $1."

    if [ -h $DST ]; then
        echo "Symlink detected, removing it."
        rm $DST
    elif [ -e $DST ]; then
        echo "Regular file detected, leaving it alone."
    else
        echo "Nothing to be done."
    fi
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
        eval "$SUDO \"apt-get install -y $(echo "$DEPENDS" | tr '\n' ' ')\"" || exit 1;
    fi
}

main $@

#ln -s /usr/lib/x86_64-linux-gnu/libclang.so.1 /usr/lib/x86_64-linux-gnu/libclang.so
#sudo apt-get install vim-scripts vim-youcompleteme
#vim-addon-manager install youcompleteme doxygen-toolkit
