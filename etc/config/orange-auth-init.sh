#!/bin/sh /etc/rc.common

# Init script to generate AUTH on boot - renews auth to avoid Orange expiry

# integration in openwrt 24.10
# ln -s /etc/config/orange-auth-init.sh /etc/init.d/orange-auth
# /etc/init.d/orange-auth enable

START=09

start() {
    /etc/config/orange-gen-auth.sh
}

