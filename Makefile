all: sync

sync:
	mkdir -p ~/.kube
	mkdir -p ~/.local/bin

	[ -f ~/.bash_aliases ] || ln -s $(PWD)/.bash_aliases ~/.bash_aliases
	[ -f ~/.bash_envs ] || ln -s $(PWD)/.bash_envs ~/.bash_envs
	[ -f ~/.bash_functions ] || ln -s $(PWD)/.bash_functions ~/.bash_functions
	[ -f ~/.bashrc ] || ln -s $(PWD)/.bashrc ~/.bashrc


	# don't show last login message
	touch ~/.hushlogin

clean:
	rm -f ~/.bash_aliases 
	rm -f ~/.bash_envs
	rm -f ~/.bash_functions
	rm -f ~/.bashrc

.PHONY: all clean sync 