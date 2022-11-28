#!/bin/sh

EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php

if [ -f composer.phar ]; then
	if [ ! -d /var/local/composer ]; then
		mkdir -p /var/local/composer
	fi
	mv composer.phar /var/local/composer/
	if [ -f /var/local/composer/composer.phar ]; then
		chmod +x /var/local/composer/composer.phar
		ln -s /var/local/composer/composer.phar /usr/local/bin/composer
	fi
fi

exit $RESULT