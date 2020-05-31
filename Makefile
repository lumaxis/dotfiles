SHELL = /bin/bash -o pipefail
DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)

.PHONY: test

all: $(OS)

macos: sudo brew change-shell node ruby packages-macos link mackup

linux: sudo core-linux brew change-shell packages-linux link

core-linux:
	sudo apt-get update
	sudo apt-get install -y build-essential curl git locales
	sudo sh -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen"
	sudo locale-gen

stow-macos: brew
	is-executable stow || brew install stow

stow-linux: core-linux
	is-executable stow || sudo apt-get -y --no-install-recommends install stow

sudo:
ifndef CI
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

packages-macos: ohmyzsh brew-packages node-packages gems python-packages

packages-linux: ohmyzsh
	/home/linuxbrew/.linuxbrew/bin/brew install starship thefuck tmux

link: stow-$(OS)
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) runcom
	stow -t $(XDG_CONFIG_HOME) config

unlink: stow-$(OS)
	stow --delete -t $(HOME) runcom
	stow --delete -t $(XDG_CONFIG_HOME) config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

brew:
	is-executable brew || curl -V >/dev/null && /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

zsh-macos: ZSH_BIN=/usr/local/bin/zsh
zsh-macos: SHELLS=/private/etc/shells
zsh-macos: brew
	if ! grep -q $(ZSH_BIN) $(SHELLS); then brew install zsh && sudo append $(ZSH_BIN) $(SHELLS); fi

zsh-linux:
	is-executable zsh || sudo apt-get install -y --no-install-recommends zsh

change-shell: zsh-$(OS)
ifndef CI
	sudo chsh -s $$(which zsh)
endif

ohmyzsh: OH_MY_ZSH_HOME="$(XDG_CONFIG_HOME)/oh-my-zsh"
ohmyzsh:
	[[ -d $(OH_MY_ZSH_HOME) ]] || curl -V >/dev/null && curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | ZSH=$(OH_MY_ZSH_HOME) sh

nodenv: brew
	is-executable nodenv || export PATH=$(HOME)/.nodenv/shims:$(PATH); curl -V >/dev/null && curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash

node: nodenv

rbenv: brew
	is-executable rbenv || brew install rbenv

ruby: LATEST_RUBY=$(shell rbenv install -l | grep -v - | tail -1)
ruby: brew rbenv
ifndef CI
	rbenv install -s $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)
endif

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

cask-apps: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Caskfile
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: node
	npm install -g $(shell cat install/npmfile)

gems: ruby
	export PATH=$(HOME)/.rbenv/shims:$(PATH); gem install -N $(shell cat install/Gemfile)

python-packages: brew
	pip3 install -q $(shell cat install/pipfile)

mackup: link
	# Necessary until [#632](https://github.com/lra/mackup/pull/632) is fixed
	ln -s ~/.config/mackup/.mackup.cfg ~
	ln -s ~/.config/mackup/.mackup ~

test:
	bats test/*.bats
