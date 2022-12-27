#!/usr/bin/env bash

FOR_USER="$1"
if [[ "$FOR_USER" == "" ]]; then
    FOR_USER="$( whoami )"
fi

su $FOR_USER -p -c "echo && \
    echo -e \"While I am installing \033[032mnode\033[0m I am user \033[032m\$( whoami )\033[0m (\033[032m\$UID\033[0m).\" && \
    if [[ \$( whoami ) == \"root\" ]]; then export HOME=\"/root\"; else export HOME=\"/home/\$(whoami)\"; fi
    echo -e \"I just made sure my home directory is \033[032m\$HOME\033[0m.\" && \
    if [[ -f ~/.bashrc ]] && [[ $( cat ~/.bashrc | grep 'export HOME=' | wc -l ) -eq 0 ]]; then echo \"export HOME=\\\"\$HOME\\\"\" >> ~/.bashrc; fi && \
    export NODE_VERSION=\"18.12.1\" && \
    if [[ -f ~/.bashrc ]]; then echo \"export NODE_VERSION=\\\"\$NODE_VERSION\\\"\" >> ~/.bashrc; fi && \
    export NVM_DIR=\"\$HOME/.nvm\" && \
    export NODE_PATH=\"\$NVM_DIR/v\$NODE_VERSION/lib/node_modules\" && \
    if [[ -f ~/.bashrc ]]; then echo \"export NODE_PATH=\\\"\$NODE_PATH\\\"\" >> ~/.bashrc; fi && \
    export PATH=\"\$NVM_DIR/versions/node/v\$NODE_VERSION/bin:\$PATH\" && \
    if [[ -f ~/.bashrc ]]; then echo \"export PATH=\\\"\$PATH\\\"\" >> ~/.bashrc; fi && \
    echo \"Some exports I will use now are:\" && \
    echo -e \"NODE_VERSION: \033[032m\$NODE_VERSION\033[0m\" && \
    echo -e \"NVM_DIR: \033[032m\$NVM_DIR\033[0m\" && \
    echo -e \"NODE_PATH: \033[032m\$NODE_PATH\033[0m\" && \
    echo -e \"PATH: \033[032m\$PATH\033[0m\" && \
    if [ ! -d \"\$NVM_DIR\" ]; then mkdir -p \"\$NVM_DIR\"; fi && \
    echo && \
    curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.3/install.sh | bash && \
    [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\" && \
    [ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\" && \
    echo && \
    echo -e -n \"\033[032m\$NVM_DIR/nvm.sh\033[0m exists: \033[032m\" && ( ls -1a \"\$NVM_DIR/\" | grep \"nvm.sh\" | wc -l ) && echo -e -n \"\033[0m\" && \
    source \$NVM_DIR/nvm.sh && \
    echo && \
    nvm install \$NODE_VERSION && \
    nvm alias default \$NODE_VERSION && \
    nvm use default && \
    npm install -g npm@latest && \
    echo"
