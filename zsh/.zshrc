export PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$PATH

# This allows to use VSCode as cli with "code" command
export PATH=/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:$PATH

# This adds brew to the path
eval "$(/opt/homebrew/bin/brew shellenv)"

# These are brew dependencies keg only which need path override to be used correctly
export PATH=/usr/local/sbin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/opt/homebrew/opt/icu4c/bin:$PATH
export PATH=/opt/homebrew/opt/icu4c/sbin:$PATH
export PATH=/opt/homebrew/opt/node@10/bin:$PATH
export PATH=/opt/homebrew/opt/gnu-getopt/bin:$PATH
export PATH=/opt/homebrew/opt/ruby/bin:$PATH
export PATH=/opt/homebrew/opt/openssl/bin:$PATH
export PATH=/opt/homebrew/opt/openldap/bin:$PATH
export PATH=/opt/homebrew/opt/openldap/sbin:$PATH
export PATH=/opt/homebrew/opt/libiconv/bin:$PATH
export PATH=/opt/homebrew/opt/apr/bin:$PATH
export PATH=/opt/homebrew/opt/apr-util/bin:$PATH
export PATH=/opt/homebrew/opt/httpd/bin:$PATH
export PATH=/opt/homebrew/opt/python/libexec/bin:$PATH
export PATH="$HOME/.symfony5/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="jolimbo"

# Handle NVM config
export NVM_DIR=~/.nvm
nvmSource=$(brew --prefix nvm)/nvm.sh
if test -f $nvmSource; then
    source $nvmSource
fi

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    composer
    chucknorris
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR="emacs"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Bat theme
export BAT_THEME='Dracula'

# Enable zsh syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fuzzy search (ctrl+r)
eval "$(fzf --zsh)"
