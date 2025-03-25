# dotfiles

These are my dotfiles. Take anything you want, but at your own risk.

It targets macOS systems, but it should work on \*nix as well (with `apt-get`).

## Package overview

- [Homebrew](https://brew.sh) (packages: [Brewfile](./install/Brewfile))
- [homebrew-cask](https://caskroom.github.io) (packages: [Brewfile](./install/Brewfile))
- [Node.js + npm LTS](https://nodejs.org/en/download/) (packages: [npmfile](./install/npmfile))
- Latest Ruby (packages: [Gemfile](./install/Gemfile))
- Latest Git, Bash 4, Python 3, GNU coreutils, curl
- [Mackup](https://github.com/lra/mackup) (sync application settings)
- `$EDITOR` (and Git editor) is [VS Code](https://code.visualstudio.com/)

## Install

On a sparkling fresh installation of macOS:

```shell-script
sudo softwareupdate -i -a
xcode-select --install
```

The Xcode Command Line Tools includes `git` and `make` (not available on stock macOS).
Then, install this repo with `curl` available:

```shell-script
bash -c "`curl -fsSL https://raw.githubusercontent.com/lumaxis/dotfiles/main/remote-install.sh`"
```

This will clone (using `git`), or download (using `curl` or `wget`), this repo to `~/dotfiles`. Alternatively, clone manually into the desired location:

```shell-script
git clone https://github.com/lumaxis/dotfiles.git ~/dotfiles
```

Use the [Makefile](./Makefile) to install everything [listed above](#package-overview), and symlink [runcom](./runcom) and [config](./config) (using [stow](https://www.gnu.org/software/stow/)):

```shell-script
cd ~/dotfiles
make
```

## Post-install

- `dotfiles dock` (set [Dock items](./macos/dock.sh))
- `dotfiles macos` (set [macOS defaults](./macos/defaults.sh))
- Mackup
  - Log in to iCloud (and wait until synced!)
  - `mackup restore`

## The `dotfiles` command

    $ dotfiles help
    Usage: dotfiles <command>

    Commands:
       clean            Clean up caches (brew, gem)
       dock             Apply macOS Dock settings
       edit             Open dotfiles in IDE (code) and Git GUI (stree)
       help             This help message
       macos            Apply macOS system defaults
       test             Run tests
       update           Update packages and pkg managers (OS, brew, npm, gem)

Alternatively, you can have an additional, personal dotfiles repo at `~/.extra`. The runcom `.zhsrc` sources all `~/.extra/runcom/*.sh` files.

## Additional resources

- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
- [Homebrew](https://brew.sh)
- [Homebrew Cask](http://caskroom.io)
- [Bash prompt](https://wiki.archlinux.org/index.php/Color_Bash_Prompt)
- [Solarized Color Theme for GNU ls](https://github.com/seebi/dircolors-solarized)

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io).

## License

These files are licensed under the [MIT license](./licenses/MIT) except the following files which are taken from [Mike McQuaid](https://github.com/MikeMcQuaid/dotfiles) and are licensed under the [GPLv3 license](./licenses/GPLv3):

- [bin/git-credential-dotfiles](./bin/git-credential-dotfiles)
- [bin/git-gpg-dotfiles](./bin/git-gpg-dotfiles)
- [bin/touchid-enable-pam-sudo](./bin/touchid-enable-pam-sudo)
