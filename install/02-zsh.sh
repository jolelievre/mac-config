#!/bin/sh

BASEDIR=$(dirname "$0")
REPO_DIR=$(cd "$BASEDIR/.." && pwd)

# Write a stub that sources the repo file, keeping room below the source
# line for machine-specific config. Converts old plain copies (backup kept),
# leaves existing stubs and their local additions untouched.
write_source_stub() {
    _src="$1"; _target="$2"; _label="$3"

    if [ -f "$_target" ] && grep -qF "source $_src" "$_target"; then
        echo "  [ok]        $_label (already sources repo file)"
        return
    fi

    _status="new"
    if [ -f "$_target" ]; then
        mv "$_target" "$_target.backup"
        _status="converted"
    fi

    cat > "$_target" <<EOF
# Shared config from mac-config repo - edit common config there.
source $_src

# Machine-specific config below this line.
EOF

    if [ "$_status" = "converted" ]; then
        echo "  [converted] $_label (backup: $_target.backup)"
    else
        echo "  [new]       $_label -> sources $_src"
    fi
}

echo Install ZSH config
write_source_stub "$REPO_DIR/zsh/.zshrc" ~/.zshrc ".zshrc"

if test ! -f /opt/homebrew/bin/zsh; then
    echo Install ZSH
    brew install zsh
fi

if test ! -d ~/.oh-my-zsh; then
    echo "Install OhMyZSH (a new instance of ZSH might be open exit it to continue the installation)"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # OhMyZSH setup its own default config on install
    echo "Forcing zsh config"
    write_source_stub "$REPO_DIR/zsh/.zshrc" ~/.zshrc ".zshrc"
fi

echo Install Fonts
cp $BASEDIR/../fonts/* ~/Library/Fonts/

if test ! -d /opt/homebrew/share/zsh-syntax-highlighting; then
    echo Install ZSH Syntax highlighting
    brew install zsh-syntax-highlighting
fi

echo Install Aliases
write_source_stub "$REPO_DIR/zsh/.oh-my-zsh/custom/aliases.zsh" ~/.oh-my-zsh/custom/aliases.zsh "aliases.zsh"

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
