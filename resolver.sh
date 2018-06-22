#!/bin/bash

# Load env file
. .env

COMMON_RESOLV_FILE=/etc/resolv.conf
UBUNTU_RESOLV_FILE=$COMMON_RESOLV_FILE

read -r -d '' RESOLVER_BODY_DARWIN << EOM
# Generated by druidfi/stonehenge
nameserver 127.0.0.1
port 53
EOM

read -r -d '' RESOLVER_BODY_LINUX << EOM
nameserver 127.0.0.1
EOM

main () {
    if [ "$(uname)" == "Darwin" ]; then
        RESOLVER_FILE=/etc/resolver/$DOCKER_DOMAIN
        sudo sh -c "echo '$RESOLVER_BODY_DARWIN' > /etc/resolver/$DOCKER_DOMAIN" && echo "Resolver file created"
    else
        if [  -n "$(uname -a | grep Ubuntu)" ]; then
            # Stop Ubuntu default DNS server
            sudo service systemd-resolved stop
        fi

        RESOLVER_FILE=$COMMON_RESOLV_FILE
        grep -qF -- "$RESOLVER_BODY_LINUX" "$RESOLVER_FILE" || sudo echo "$RESOLVER_BODY_LINUX" >> "$RESOLVER_FILE"
    fi

    exit 0
}

main