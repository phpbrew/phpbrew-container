FROM  ubuntu:14.04
# FROM  debian:jessie

MAINTAINER Yo-An Lin "yoanlin93@gmail.com"

USER root

ENV DEBIAN_FRONTEND noninteractive

ENV PHP_VERSION 5.6

ENV PHP_SUBVERSION $PHP_VERSION.10

ENV PHPBREW_ROOT /root/.phpbrew

ENV PHPBREW_HOME /root/.phpbrew

ENV PHPBREW_PHP php-$PHP_VERSION.10

ENV PHPBREW_SET_PROMPT 1


# Remove default dash and replace it with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN echo "Asia/Taipei" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

RUN perl -i.bak -pe "s/archive.ubuntu.com/free.nchc.org.tw/g" /etc/apt/sources.list

RUN export DEBIAN_FRONTEND="noninteractive" \
  && apt-get update \
  && apt-get build-dep -y php5 \
  && apt-get -qqy install php5 \
  && apt-get -qqy install php5-dev \
  && apt-get -qqy install php5-cli \
  && apt-get -qqy install php-apc \
  && apt-get -qqy install php-pear \
  && apt-get -qqy install php5-curl \
  && apt-get -qqy install php5-fpm \
  && apt-get -qqy install php5-gd \
  && apt-get -qqy install php5-mysql \
  && apt-get -qqy install php5-xdebug \
  && apt-get -qqy install autoconf automake curl build-essential libxslt1-dev re2c libxml2 libxml2-dev php5-cli bison libbz2-dev libreadline-dev \
  && apt-get -qqy install libfreetype6 libfreetype6-dev libpng12-0 libpng12-dev libjpeg-dev libjpeg8-dev libjpeg8 libgd-dev libgd3 libxpm4 libltdl7 libltdl-dev \
  && apt-get -qqy install libssl-dev openssl \
  && apt-get -qqy install gettext libgettextpo-dev libgettextpo0 \
  && apt-get -qqy install libicu-dev \
  && apt-get -qqy install libmhash-dev libmhash2 \
  && apt-get -qqy install libmcrypt-dev libmcrypt4 \
  && apt-get -qqy install mysql-server mysql-client libmysqlclient-dev libmysqld-dev \
  && apt-get -qqy install ca-certificates \
  && apt-get -qqy install libyaml-dev libyaml-0-2 \
  && apt-get -qqy install libcurl4-gnutls-dev libcurl4-openssl-dev libexpat1-dev libz-dev librecode0 \
  && apt-get -qqy install libpcre3-dev libpcre++-dev \
  && apt-get -qqy install git \
  && apt-get -qqy install wget \
  && apt-get -qqy install curl \
  && apt-get -qqy install ant ant-contrib sqlite3 \
  && apt-get clean -y \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && rm -rf /var/lib/apt/lists/*

# Install php tools
RUN mkdir -p /usr/bin \
  && wget -q -O /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/bin/phpunit \
  && wget -q -O /usr/bin/composer https://getcomposer.org/composer.phar && chmod +x /usr/bin/composer \
  && wget -q -O /usr/bin/phpmd http://static.phpmd.org/php/latest/phpmd.phar && chmod +x /usr/bin/phpmd \
  && wget -q -O /usr/bin/sami http://get.sensiolabs.org/sami.phar && chmod +x /usr/bin/sami \
  && wget -q -O /usr/bin/phpcov https://phar.phpunit.de/phpcov.phar && chmod +x /usr/bin/phpcov \
  && wget -q -O /usr/bin/phpcpd https://phar.phpunit.de/phpcpd.phar && chmod +x /usr/bin/phpcpd \
  && wget -q -O /usr/bin/phploc https://phar.phpunit.de/phploc.phar && chmod +x /usr/bin/phploc \
  && wget -q -O /usr/bin/phptok https://phar.phpunit.de/phptok.phar && chmod +x /usr/bin/phptok \
  && wget -q -O /usr/bin/box https://github.com/box-project/box2/releases/download/2.5.2/box-2.5.2.phar && chmod +x /usr/bin/box \
  && wget -q -O /usr/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew && chmod +x /usr/bin/phpbrew


RUN phpbrew init \
  && echo 'source $HOME/.phpbrew/bashrc' >> /root/.bashrc \
  && source ~/.phpbrew/bashrc \
  && phpbrew install $PHP_SUBVERSION \
              +default +bcmath +bz2 +calendar +cli +ctype +dom +fileinfo +filter +json \
              +mbregex +mbstring +mhash +pcntl +pcre +pdo +phar +posix +readline +sockets \
              +tokenizer +xml +curl +zip +openssl=yes +icu +opcache +fpm +sqlite +mysql +icu +default +intl +gettext

RUN  phpbrew ext install yaml -- --with-yaml=/usr/lib/x86_64-linux-gnu \
  && phpbrew ext install gd -- --with-png-dir=/opt/local --with-jpeg-dir=/opt/local --with-freetype-dir=/opt/local --enable-gd-native-ttf \
  && phpbrew ext install github:c9s/cssmin \
  && phpbrew ext install github:sqmk/pecl-jsmin \
  && phpbrew ext install github:c9s/php-fileutil \
  && phpbrew ext install xdebug latest \
  && phpbrew ext install apcu latest

RUN echo "Asia/Taipei" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

COPY php.ini $PHPBREW_ROOT/php/php-$PHP_SUBVERSION/etc/php.ini

VOLUME /home/ubuntu
WORKDIR /home/ubuntu

COPY build.sh /home/ubuntu/build.sh
ENTRYPOINT ["/home/ubuntu/build.sh"]
