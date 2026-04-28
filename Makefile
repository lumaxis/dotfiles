SHELL = /bin/bash -o pipefail
DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)bin:/opt/homebrew/bin:/usr/local/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)

.PHONY: test

all: $(OS)

macos: sudo brew change-shell mise node ruby packages-macos link mackup

linux: sudo core-linux change-shell packages-linux link

core-linux:
	sudo apt-get update
	is-executable curl || sudo apt-get install -y curl
	is-executable gcc || sudo apt-get install -y build-essential
	is-executable git || sudo apt-get install -y git
	is-executable locales || sudo apt-get install -y locales
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
	export FORCE=1; curl -fsSL https://starship.rs/install.sh | sh

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
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

zsh-macos: ZSH_BIN=/opt/homebrew/bin/zsh
zsh-macos: SHELLS=/etc/shells
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
	test -d $(OH_MY_ZSH_HOME) || curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | ZSH=$(OH_MY_ZSH_HOME) sh

mise: brew
	is-executable mise || brew install mise

mise-node: mise
	mise use --global node@lts

node: mise-node

mise-ruby: mise
	mise use --global ruby@latest

ruby: mise-ruby

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

apps: brew
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: node
	eval "$$(mise env)" && npm install -g $(shell cat install/npmfile)

gems: ruby
	eval "$$(mise env)" && gem install -N $(shell cat install/Gemfile)

python-packages: brew
	pip3 install -q $(shell cat install/pipfile)

mackup: link
	ln -s ~/.config/mackup/.mackup ~

test:
	bats test/*.bats
