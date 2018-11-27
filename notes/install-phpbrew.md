Installation PHPBrew

Requirements:
Install brew
brew install libpng
brew install icu4c v58

brew install --force https://raw.githubusercontent.com/ilovezfs/homebrew-core/d2485c72643aa7e6aec0da9ced3aa66401ae42ce/Formula/icu4c.rb

export CPPFLAGS='-std=c++11 -DU_USING_ICU_NAMESPACE=1'
phpbrew install 5.6 +default +intl +mysql +apxs2 +soap +fileinfo

phpbrew use 5.6.30
phpbrew ext install xdebug
phpbrew ext install gd \
-- --with-gd=shared \
--enable-gd-native-ttf \
--with-jpeg-dir=/usr/local/opt/libjpg/ \
--with-png-dir=/usr/local/opt/libpng/ \
--with-zlib-dir=/usr/local/opt/zlib/

phpbrew ext install iconv

CXXFLAGS='-std=c++11 -stdlib=libc++' phpbrew --debug install php-7.1 +default +intl +mysql +apxs2 +soap +fileinfo -- --with-openssl

