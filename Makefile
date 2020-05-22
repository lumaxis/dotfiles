SHELL = ./report_time.sh
DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)

.PHONY: test

all: $(OS)

macos: sudo core-macos packages link mackup

linux: sudo core-linux brew-linux link
	/home/linuxbrew/.linuxbrew/bin/brew install starship thefuck

core-macos: brew-macos change-shell node ruby

core-linux: ZSH="$(XDG_CONFIG_HOME)/oh-my-zsh"
core-linux:
	sudo apt-get update
	sudo apt-get install build-essential locales -y
	sudo sh -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen"
	sudo locale-gen
	[[ -d $(ZSH) ]] || curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | ZSH=$(ZSH) sh

stow-macos: brew-macos
	is-executable stow || brew install stow

stow-linux: core-linux
	is-executable stow || sudo apt-get -y install stow

sudo:
ifndef CI
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

packages: brew-packages node-packages gems python-packages

link: stow-$(OS)
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) runcom
	stow -t $(XDG_CONFIG_HOME) config

unlink: stow-$(OS)
	stow --delete -t $(HOME) runcom
	stow --delete -t $(XDG_CONFIG_HOME) config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

brew-macos:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby

brew-linux:
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh | bash

zsh: ZSH=/usr/local/bin/zsh
zsh: SHELLS=/private/etc/shells
zsh: brew-$(OS)
	if ! grep -q $(ZSH) $(SHELLS); then brew install zsh && sudo append $(ZSH) $(SHELLS); fi

change-shell: zsh
ifndef CI
	chsh -s $(ZSH)
endif

nodenv: brew-$(OS)
	is-executable nodenv || export PATH=$(HOME)/.nodenv/shims:$(PATH); curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash

node: nodenv

rbenv: brew-$(OS)
	is-executable rbenv || brew install rbenv

ruby: LATEST_RUBY=$(shell rbenv install -l | grep -v - | tail -1)
ruby: brew-$(OS) rbenv
ifndef CI
	rbenv install -s $(LATEST_RUBY)
	rbenv global $(LATEST_RUBY)
endif

brew-packages: brew-$(OS)
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

cask-apps: brew-macos
	brew bundle --file=$(DOTFILES_DIR)/install/Caskfile
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: node
	npm install -g $(shell cat install/npmfile)

gems: ruby
	export PATH=$(HOME)/.rbenv/shims:$(PATH); gem install -N $(shell cat install/Gemfile)

python-packages: brew-$(OS)
	pip3 install -q $(shell cat install/pipfile)

mackup: link
	# Necessary until [#632](https://github.com/lra/mackup/pull/632) is fixed
	ln -s ~/.config/mackup/.mackup.cfg ~
	ln -s ~/.config/mackup/.mackup ~

test:
	bats test/*.bats
