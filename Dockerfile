# syntax=docker/dockerfile:1

ARG UID=1000
ARG GID=1000
ARG RELEASE=8.1
ARG MAINTAINER="nullester"

FROM ${MAINTAINER}/ubuntu:latest as builder

ARG UID
ARG GID
ARG RELEASE
ARG MAINTAINER
ARG PHP_VERS=${RELEASE:-8.1}

RUN echo "Maintainer is \033[032m${MAINTAINER}\033[0m"
LABEL maintainer="${MAINTAINER}"

ENV	DEBCONF_NONINTERACTIVE_SEEN="true" \
	DEBIAN_FRONTEND="noninteractive" \
	HOME="/root" \
	LC_ALL="C.UTF-8" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8" \
	TZ="${TZ:-Europe/Brussels}" \
	TERM="xterm" \
	PHP_VERS="$PHP_VERS" \
	PUID="${UID:-1000}" \
	PGID="${GID:-1000}"

RUN echo && echo "Using PHP version \033[032m${PHP_VERS}\033[0m" && echo

# Upgrade
FROM builder as build1
RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && \
	apt-get -y upgrade -o Dpkg::Options::="--force-confold" && \
	apt-get -y dist-upgrade -o Dpkg::Options::="--force-confold"

# PHP & Apache
FROM build1 as build2
RUN	apt-get -y install \
    locales \
    curl \
    wget \
    gnupg \
    ca-certificates \
    software-properties-common \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zlib1g-dev \
    zip \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    unzip \
    libgd-dev \
    p7zip \
    apache2 \
    mysql-client \
    ssmtp mailutils \
    php$PHP_VERS php$PHP_VERS-fpm libapache2-mod-php$PHP_VERS \
    php$PHP_VERS-mysql php$PHP_VERS-gd php$PHP_VERS-zip php$PHP_VERS-mbstring php$PHP_VERS-xml php$PHP_VERS-intl php$PHP_VERS-curl

# Composer
FROM build2 as build3
COPY install-composer.sh /usr/src/app/install-composer.sh
RUN cd /usr/src/app && chmod +x install-composer.sh && sh install-composer.sh && rm install-composer.sh

# Helpers
FROM build3 as build4
RUN echo '#!/bin/bash' > /usr/local/bin/php-major-version && \
    echo -n "php -r 'echo PHP_MAJOR_VERSION;'" >> /usr/local/bin/php-major-version && \
    chmod +x /usr/local/bin/php-major-version
RUN echo '#!/bin/bash' > /usr/local/bin/php-minor-version && \
    echo -n "php -r 'echo PHP_MAJOR_VERSION." >> /usr/local/bin/php-minor-version && \
    echo -n '"."' >> /usr/local/bin/php-minor-version && \
    echo ".PHP_MINOR_VERSION;'" >> /usr/local/bin/php-minor-version && \
    chmod +x /usr/local/bin/php-minor-version
RUN echo '#!/bin/bash' > /usr/local/bin/php-release-version && \
    echo -n "php -r 'echo PHP_MAJOR_VERSION." >> /usr/local/bin/php-release-version && \
    echo -n '"."' >> /usr/local/bin/php-release-version && \
    echo -n ".PHP_MINOR_VERSION." >> /usr/local/bin/php-release-version && \
    echo -n '"."' >> /usr/local/bin/php-release-version && \
    echo ".PHP_RELEASE_VERSION;'" >> /usr/local/bin/php-release-version && \
    chmod +x /usr/local/bin/php-release-version

# Users and permissions
FROM build4 as build5
RUN chown -R www-data:www-data /var/www/html
RUN usermod -a -G www-data docker
RUN usermod -a -G docker www-data

# Apache2 confs
FROM build5 as build6
RUN a2enmod php$PHP_VERS proxy_fcgi ssl rewrite expires headers
RUN a2enconf php$PHP_VERS-fpm

# Prepare entrypoint
FROM build6 as build7
COPY entrypoint.sh /entry/lap
RUN chmod +x /entry/lap

# Expose ports
FROM build7 as build8
EXPOSE 80 443

# Set volumes
FROM build8 as build9
VOLUME \
    ["/var/www/html"]

# FROM build9
# ENTRYPOINT ["/entry/lap"]
