FROM  ubuntu:20.04
# FROM  debian:jessie
 
MAINTAINER Yo-An Lin "yoanlin93@gmail.com"
 
USER root
 
ENV DEBIAN_FRONTEND noninteractive
 
ENV PHP_VERSION 7.4
 
ENV PHP_SUBVERSION $PHP_VERSION.10
 
ENV PHPBREW_ROOT /root/.phpbrew
 
ENV PHPBREW_HOME /root/.phpbrew
 
ENV PHPBREW_PHP php-$PHP_VERSION.10
 
ENV PHPBREW_SET_PROMPT 1
 
 
# Remove default dash and replace it with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
 
RUN echo "Asia/Taipei" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
 
RUN perl -i.bak -pe "s/archive.ubuntu.com/g" /etc/apt/sources.list
 
RUN export DEBIAN_FRONTEND="noninteractive" \
  && apt-get update \
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
  && wget -q -O /usr/bin/composer https://getcomposer.org/composer.phar && chmod +x /usr/bin/composer \
  && wget -q -O /usr/bin/phpbrew https://github.com/phpbrew/phpbrew/raw/master/phpbrew && chmod +x /usr/bin/phpbrew
 
 
RUN phpbrew init \
  && echo 'source $HOME/.phpbrew/bashrc' >> /root/.bashrc \
  && source ~/.phpbrew/bashrc \
  && phpbrew install $PHP_SUBVERSION \
              +default +bcmath +bz2 +calendar +cli +ctype +dom +fileinfo +filter +json \
              +mbregex +mbstring +mhash +pcntl +pcre +pdo +phar +posix +readline +sockets \
              +tokenizer +xml +curl +zip +openssl=yes +icu +opcache +fpm +sqlite +mysql +icu +default +intl +gettext
 
RUN  phpbrew --debug install 7.4 +default +mysql +sqlite +mb +debug +fpm +intl +openssl=/usr/local/opt/openssl +bz2=/usr/local/opt/bzip2 +zlib=/usr/local/opt/zlib +apxs2=/usr/bin/apxs2 -- --enable-maintainer-zts
RUN  phpbrew ext install parallel -- --enable-parallel-coverage --enable-parallel-dev
 
RUN echo "Asia/Taipei" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
 
COPY php.ini $PHPBREW_ROOT/php/php-$PHP_SUBVERSION/etc/php.ini
 
VOLUME /home/ubuntu
WORKDIR /home/ubuntu
 
COPY build.sh /home/ubuntu/build.sh
ENTRYPOINT ["/home/ubuntu/build.sh"]
