###############################################################################
# Makefile - dotfiles helper
#
# Targets:
#   all (default) : Runs 'sync'
#   backup        : Move existing real .bash* files (not symlinks, excluding *history*)
#                   into ${BACKUP_DIR:-$HOME/.dotfiles_backup}/YYYYmmdd_HHMMSS unless
#                   SKIP_BACKUP=1
#   sync          : Depends on backup. Create ~/.kube & ~/.local/bin and symlink
#                   core bash dotfiles from repo into $HOME (skips if present)
#   clean         : Remove the created symlinks (does NOT delete originals)
#
# Usage:
#   make              # backup (unless SKIP_BACKUP) then symlink
#   make backup       # only perform backup step
#   make clean        # remove symlinks
# Env:
#   SKIP_BACKUP=1     # skip backup stage
#   BACKUP_DIR=/path  # override backup root (default: $HOME/.dotfiles_backup)
# Notes:
#   Adjust list if adding new dotfiles. Idempotent: skip link if already present.
###############################################################################

all: sync

backup: ## Backup existing real .bash* files into unique timestamped directory (never overwrites or removes last backup)
ifeq ($(SKIP_BACKUP),1)
	@echo "Skipping backup (SKIP_BACKUP=1)"
else
	@ts=$$(date +%Y%m%d_%H%M%S); \
	 root="$${BACKUP_DIR:-$$HOME/.dotfiles_backup}"; mkdir -p "$$root"; \
	 base="$$root/$$ts"; dest="$$base"; n=1; \
	 while [ -e "$$dest" ]; do dest="$$base_$$n"; n=$$((n+1)); done; \
	 mkdir -p "$$dest"; moved=0; \
	 for f in $$(find $$HOME -maxdepth 1 -type f -name '.bash*'); do \
	   case $$f in *history*) continue ;; esac; \
	   case $$f in *private*) continue ;; esac; \
	   if [ ! -L "$$f" ]; then \
	     mv "$$f" "$$dest/" && moved=1; \
	   fi; \
	 done; \
	 if [ $$moved -eq 0 ]; then echo "No real .bash* files to backup (created $$dest anyway)"; else echo "Backup created at $$dest"; fi
endif

sync: backup ## Symlink bash dotfiles into $HOME (safe, skips existing)
	mkdir -p ~/.kube
	mkdir -p ~/.local/bin

	[ -f ~/.bash_aliases ] || ln -s $(PWD)/.bash_aliases ~/.bash_aliases
	[ -f ~/.bash_envs ] || ln -s $(PWD)/.bash_envs ~/.bash_envs
	[ -f ~/.bash_functions ] || ln -s $(PWD)/.bash_functions ~/.bash_functions
	[ -f ~/.bash_logout ] || ln -s $(PWD)/.bash_logout ~/.bash_logout
	[ -f ~/.bash_profile ] || ln -s $(PWD)/.bash_profile ~/.bash_profile
	[ -f ~/.bashrc ] || ln -s $(PWD)/.bashrc ~/.bashrc


	# don't show last login message
	touch ~/.hushlogin

clean: ## Remove symlinked bash dotfiles from $HOME
	rm -f ~/.bash_aliases 
	rm -f ~/.bash_envs
	rm -f ~/.bash_functions
	rm -f ~/.bash_logout
	rm -f ~/.bash_profile
	rm -f ~/.bashrc

.PHONY: all backup clean sync