#!/bin/sh

BASEDIR=$(dirname "$0")

if test ! -f ~/.zshrc; then
    echo Install ZSH config
    cp $BASEDIR/../zsh/.zshrc ~/.zshrc
fi

if test ! -f /opt/homebrew/bin/zsh; then
    echo Install ZSH
    brew install zsh
fi

if test ! -d ~/.oh-my-zsh; then
    echo "Install OhMyZSH (a new instance of ZSH might be open exit it to continue the installation)"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # OhMyZSH setup its own default config on install
    echo "Forcing zsh config"
    cp $BASEDIR/../zsh/.zshrc ~/.zshrc
fi

echo Install Fonts
cp $BASEDIR/../fonts/* ~/Library/Fonts/

if test ! -d /opt/homebrew/share/zsh-syntax-highlighting; then
    echo Install ZSH Syntax highlighting
    brew install zsh-syntax-highlighting
fi

if test ! -f ~/.oh-my-zsh/custom/aliases.zsh; then
    echo Install Aliases
    cp $BASEDIR/../zsh/.oh-my-zsh/custom/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
fi

if test ! -f ~/.oh-my-zsh/custom/themes/jolimbo.zsh-theme; then
    echo Install Jolimbo Theme
    cp $BASEDIR/../zsh/.oh-my-zsh/custom/themes/jolimbo.zsh-theme ~/.oh-my-zsh/custom/themes/jolimbo.zsh-theme
fi

if test ! -d /opt/homebrew/opt/gnu-getopt; then
    echo Install gnu-getopt
    brew install gnu-getopt
fi

if test ! -f /opt/homebrew/bin/wget; then
    echo Install wget
    brew install wget
fi

if test ! -f /opt/homebrew/bin/emacs; then
    echo Install emacs
    brew install emacs
fi

# Dependencies for chuck norris plugin
brew install fortune
brew install cowthink

# Fuzzy find
brew install fzf

# Bat, hyper cat
brew install bat
mkdir -p "$(bat --config-dir)/themes"
