#!/bin/bash

if [[ "$USER" != "root" ]]; then
    sudo apachectl -D FOREGROUND
else
    apachectl -D FOREGROUND
fi
