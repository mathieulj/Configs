install:
	PWD=$(shell pwd)
	mkdir -p ~/.vim/colors
	ln -s ${PWD}/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/solarized.vim 
	mkdir -p ~/.vim/syntax
	ln -s ${PWD}/../c.vim ~/.vim/syntax/c.vim

depends:
	apt-get install vim-nox clang vim-youcompleteme vim-snippets vim-snipmate vim-scripts

symlink:
	cd /usr/lib/x86_64-linux-gnu/
	ln -s libclang.so.1 libclang.so
