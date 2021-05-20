FROM  ubuntu:20.04
# FROM  debian:jessie

MAINTAINER Yo-An Lin "yoanlin93@gmail.com"

ENV PHP_SUBVERSION 7.4
ENV PHPBREW_ROOT E:/phpbrew
ENV PHPBREW_HOME E:/phpbrew
ENV PHPBREW_PHP php-$PHP_SUBVERSION

USER root 
ENV DEBIAN_FRONTEND noninteractive
ENV PHPBREW_SET_PROMPT 1

# Remove default dash and replace it with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN perl -i.bak -pe "s/archive.ubuntu.com/archive.ubuntu.com/g" /etc/apt/sources.list

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

#RUN echo "Asia/Taipei" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata     #COMMENT: OR TRY this--->   #ARG DEBIAN_FRONTEND=noninteractive  &&  ENV TZ=Asia/Taipei  &&  RUN apt-get install -y tzdata 

COPY php.ini $PHPBREW_ROOT/php/php-$PHP_SUBVERSION/etc/php.ini

VOLUME /home/ubuntu
WORKDIR /home/ubuntu

COPY build.sh /home/ubuntu/build.sh
ENTRYPOINT ["/home/ubuntu/build.sh"]
