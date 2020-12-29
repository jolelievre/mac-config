# Custom aliases
alias l='ll'
alias e='emacs'
alias rm='rm -i'
alias -g G='| grep -i --color'

# Zsh alias plus git config alias
alias gl="git log --graph --all --decorate"

# PHP switch alias
alias sphp='~/dev/scripts/sphp.sh'
alias mphp='php -d memory_limit=-1'
alias mcomposer='mphp `which composer`'

# Prestashop install alias
if test ! -f ~/dev/ps-install-tools/aliases.sh; then
    source ~/dev/ps-install-tools/aliases.sh
fi
