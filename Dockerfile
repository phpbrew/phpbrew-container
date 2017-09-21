FROM ubuntu:16.04

MAINTAINER Gram <gram7gram@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C
ENV TIME_ZONE Europe/Kiev

ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE ${APACHE_RUN_DIR}/apache2.pid
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_MAX_REQUEST_WORKERS 32
ENV APACHE_MAX_CONNECTIONS_PER_CHILD 1024
ENV APACHE_ALLOW_OVERRIDE None
ENV APACHE_ALLOW_ENCODED_SLASHES Off

ENV PHP_VERSION 7.1.3
ENV PHPBREW_ROOT /opt/phpbrew
ENV PHPBREW_HOME /opt/phpbrew

EXPOSE 80 443

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN export DEBIAN_FRONTEND="noninteractive" && apt-get update

RUN export DEBIAN_FRONTEND="noninteractive" && \
apt-get -qqy install \
apt-utils autoconf automake curl build-essential \
libxslt1-dev re2c libxml2 libxml2-dev bison libbz2-dev libreadline-dev \
libfreetype6 libfreetype6-dev libpng12-0 libpng12-dev libjpeg-dev libjpeg8-dev libjpeg8 \
libgd-dev libgd3 libxpm4 libltdl7 libltdl-dev \
freetype2-demos libpq5 libpq-dev \
libssl-dev openssl \
gettext libgettextpo-dev libgettextpo0 \
libicu-dev \
libmhash-dev libmhash2 \
libmcrypt-dev libmcrypt4 \
ca-certificates \
libyaml-dev libyaml-0-2 \
libcurl4-gnutls-dev libexpat1-dev libz-dev librecode0 \
libpcre3-dev libpcre++-dev \
memcached \
git wget curl; exit 0

RUN export DEBIAN_FRONTEND="noninteractive" && apt-get install -f

RUN export DEBIAN_FRONTEND="noninteractive" && \
apt-get -qqy install php7.0 php7.0-dev php7.0-curl php7.0-gd; exit 0

RUN export DEBIAN_FRONTEND="noninteractive" && apt-get install -f

RUN export DEBIAN_FRONTEND="noninteractive" && \
apt-get -qqy -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew \
install apache2 apache2-dev libapache2-mod-php7.0; exit 0

RUN export DEBIAN_FRONTEND="noninteractive" && apt-get install -f

RUN export DEBIAN_FRONTEND="noninteractive" && \
apt-get clean -y && \
apt-get autoclean -y && \
apt-get autoremove -y && \
rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
rm -rf /var/lib/apt/lists/*

RUN chmod -R oga+rw /usr/lib/apache2/modules && \
chmod -R oga+rw /etc/apache2

RUN mkdir -p $PHPBREW_HOME

RUN echo "export PHPBREW_ROOT=$PHPBREW_HOME" >> /etc/profile && \
echo "export PHPBREW_HOME=$PHPBREW_HOME" >> /etc/profile && \
echo "source ${PHPBREW_HOME}/bashrc" >> /etc/profile && \
echo "source ${PHPBREW_HOME}/bashrc" >> /root/.bashrc

RUN wget -q -O /usr/bin/composer https://getcomposer.org/composer.phar && \
chmod +x /usr/bin/composer

RUN curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew && \
chmod +x phpbrew && \
mv phpbrew /usr/bin/phpbrew

RUN phpbrew init && chmod 777 -R /opt/phpbrew

RUN source ${PHPBREW_HOME}/bashrc

RUN source ${PHPBREW_HOME}/bashrc && phpbrew install $PHP_VERSION +pdo+pgsql+json+cli+cgi+readline+ctype+hash+default+apxs2+gd+curl+soap
RUN source ${PHPBREW_HOME}/bashrc && phpbrew list
RUN source ${PHPBREW_HOME}/bashrc && phpbrew switch $PHP_VERSION
RUN source ${PHPBREW_HOME}/bashrc && phpbrew use $PHP_VERSION

RUN source ${PHPBREW_HOME}/bashrc && phpbrew ext install dbase 7.0.0beta1

RUN source ${PHPBREW_HOME}/bashrc && phpbrew ext install iconv

RUN source ${PHPBREW_HOME}/bashrc && phpbrew ext install gd -- \
--with-gd=/usr/include \
--with-png-dir=/usr/include \
--with-jpeg-dir=/usr/include \
--with-freetype-dir=/usr/include

RUN source ${PHPBREW_HOME}/bashrc && phpbrew ext install memcached stable -- --disable-memcached-sasl

RUN echo "date.timezone='$TIME_ZONE'" >> $PHPBREW_HOME/php/php-$PHP_VERSION/etc/php.ini
RUN echo "memory_limit=2G" >> $PHPBREW_HOME/php/php-$PHP_VERSION/etc/php.ini

RUN echo "LoadModule php7_module $PHPBREW_HOME/build/php-$PHP_VERSION/libs/libphp$PHP_VERSION.so" > /etc/apache2/mods-available/php7.0.load

WORKDIR /var/www/html

RUN a2enmod rewrite

RUN a2enmod ssl

CMD apache2 -DFOREGROUND
