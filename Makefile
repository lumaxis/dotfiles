SHELL = /bin/zsh
DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)

.PHONY: test

all: $(OS)

macos: sudo core-macos packages link mackup

linux: sudo core-linux brew-linux link
	/home/linuxbrew/.linuxbrew/bin/brew install starship

core-macos: brew-macos zsh git npm ruby

core-linux:
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get install build-essential locales -y
	sudo apt-get dist-upgrade -y -f
	sudo locale-gen en_US.UTF-8

stow-macos: brew-macos
	is-executable stow || brew install stow

stow-linux: core-linux
	is-executable stow || sudo apt-get -y install stow

sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

packages: brew-packages cask-apps node-packages gems

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
	echo 'eval $$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> system/.custom

zsh: ZSH=/usr/local/bin/zsh
zsh: SHELLS=/private/etc/shells
zsh: brew-$(OS)
	if ! grep -q $(ZSH) $(SHELLS); then brew install zsh pcre && sudo append $(ZSH) $(SHELLS) && chsh -s $(ZSH); fi

git: brew-$(OS)
	brew install git git-extras

npm: PATH="$HOME/.nodenv/shims:$PATH"
npm: brew-$(OS)
	curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-installer | bash

ruby: brew-$(OS)
	brew install ruby

brew-packages: brew-$(OS)
	brew cask install homebrew/cask-versions/adoptopenjdk8 && brew bundle --file=$(DOTFILES_DIR)/install/Brewfile

cask-apps: brew-macos
	brew bundle --file=$(DOTFILES_DIR)/install/Caskfile
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages: npm
	. npm install -g $(shell cat install/npmfile)

gems: PATH="/usr/local/opt/ruby/bin:$PATH"
gems: ruby
	gem install $(shell cat install/Gemfile)

mackup: link
	# Necessary until [#632](https://github.com/lra/mackup/pull/632) is fixed
	ln -s ~/.config/mackup/.mackup.cfg ~

test:
	bats test/*.bats
