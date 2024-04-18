Mac installation for development environment
--------------------------------------------

Follow these steps in the appropriate order (strongly recommanded)
Or launch them based on your needs

WARNING: between each step it might be recommended to reboot your computer so that installed libraries are correctly used

# install/01-xcode.sh
- xcode

# install/01.1-brew.sh
- brew

# install/02-zsh.sh
- zsh config
- zsh
- ohmyzsh
- install zsh-syntax-highlighting
- install Fonts for zsh theme
- copy .ohmyzsh/custom folder (aliases and theme)

# install/03-apache
- uninstall OS default Apache
- brew install apache
- create basic folders with sites-enable/sites-available

# install/04-php.sh
- upgrade brew and dependencies
- install 5.6 7.0 7.1 7.2 7.3 7.4 8.0
- install script sphp
- install composer
- restart Apache

# install/05-mysql.sh
- brew install mariadb

# install/06-prestashop-tools.sh
- Clone prestashop tools repository
- Install prestashop tools scripts

# install/07-git.sh
- Set default git config (global .gitignore)

# install/08-node.sh
- Install node8
- Install gulp

# install/09-blackfire.sh
- Install blackfire agent
- Install blackfire client
- Init default setting with client id, server id, token, ...
- Install PHP probe extension for all installed PHP versions

# install/10-symfony.sh
- Symfony installer command

# install/11-ruby.sh
- Install ruby

# install/12-hugo.sh
- Install hugo

# install/13-python.sh
- Install python

# install/14-dev-apps.sh
- Sequel ACE
- PHPStorm
- Visual Studio Code
- iTerm2
- Insomnium

Applications
- iTerm2 (Go to Settings > General > Load preferences from a custom folder or URL > select this repo iterm2 folder)
- Chrome (AdBlock Plus, JSON viewer, Blackfire companion)
- Slack
- Libre Office
