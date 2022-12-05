#!/bin/bash

echo && echo -e "\033[032mI AM \033[035m$( whoami )\033[032m!\033[0m" && echo

su root -c "export HOME=/root"
su docker -c "export HOME=/home/docker"

echo -e "Starting service \033[032mapache2\033[0m"
if [[ "$USER" != "root" ]]; then
    sudo service apache2 start
else
    service apache2 start
fi
echo

echo -e "Starting service \033[032mphp${PHP_VERS}-fpm\033[0m"
if [[ "$USER" != "root" ]]; then
    sudo service php$PHP_VERS-fpm start
else
    service php$PHP_VERS-fpm start
fi
echo

echo -e "Server \033[032m${HOSTNAME}\033[0m up and running!"
tail -f /dev/null