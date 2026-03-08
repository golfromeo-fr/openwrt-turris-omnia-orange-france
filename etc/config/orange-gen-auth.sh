#!/bin/sh

# Orange France FTI/Livebox authentication script
# IMPORTANT: Orange rejects AUTH strings used for >5-8 weeks - run this periodically to renew
# Can be triggered by: /etc/init.d/orange-auth (if enabled) or hotplug on wan ifdown

# run with debug
# sh -x orange-gen-auth.sh

. /etc/config/orange-auth

SALT_PREFIX="1234567890123"
SALT_SUFFIX=$(cat /dev/urandom | tr -dc '0-9' | head -c 3)
SALT="${SALT_PREFIX}${SALT_SUFFIX}"

str_hex() {
    echo -n "$1" | hexdump -v -e '/1 "%02X:"' | sed 's/:$//'
}

tl() {
    printf "%s:%02X" "$1" "$2"
}

ORANGE="fti/${LOGIN}"
ORANGE_LEN=$(echo -n "$ORANGE" | wc -c)
SALT_LEN=16

MD5S=$(printf '%s' "${BYTE}${PASSWORD}${SALT}" \
    | md5sum | cut -d' ' -f1 \
    | sed 's/../&:/g;s/:$//' \
    | tr 'a-f' 'A-F')

AUTH="00:00:00:00:00:00:00:00:00:00:00\
:1A:09:00:00:05:58:01:03:41\
:$(tl 01 $((2+ORANGE_LEN))):$(str_hex "$ORANGE")\
:$(tl 3C $((2+SALT_LEN))):$(str_hex "$SALT")\
:$(tl 03 $((2+1+SALT_LEN))):$(str_hex "$BYTE"):${MD5S}"

# Remove only the auth entries, keep everything else
uci -q del_list network.wan.sendopts="$(uci get network.wan.sendopts | tr ' ' '\n' | grep '^90:')"
uci add_list network.wan.sendopts="90:${AUTH}"

uci -q del_list network.wan6.sendopts="$(uci get network.wan6.sendopts | tr ' ' '\n' | grep '^11:')"
uci add_list network.wan6.sendopts="11:${AUTH}"

uci commit network


logger -t orange-auth "Auth applied salt=${SALT} len=$(echo -n "$AUTH" | wc -c)"
