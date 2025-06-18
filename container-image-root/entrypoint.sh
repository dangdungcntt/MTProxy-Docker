#!/bin/bash
set -x

[ "$IP" == "" ] && IP=$(curl -s https://ipinfo.io/ip)

curl -s https://core.telegram.org/getProxySecret -o /srv/MTProxy/objs/bin/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /srv/MTProxy/objs/bin/proxy-multi.conf

if [ -z "$DISABLE_CRON" ]; then
    cron
fi;

MAX_CONNECTIONS=${MAX_CONNECTIONS:-25000}
WORKERS=${WORKERS:-1}

# Build mtproto-proxy command with conditional -P $TAG
CMD="./mtproto-proxy -u nobody -p 8888 -H 8889 -S $SECRET -c $MAX_CONNECTIONS --aes-pwd proxy-secret proxy-multi.conf -M $WORKERS --nat-info $(hostname --ip-address):$IP --http-stats"

# Add -P $TAG if TAG is set and not empty
[ -n "$TAG" ] && CMD="$CMD -P $TAG"

if [ "$1" == "" ];
then
eval "$CMD"
else
exec "$1"
fi
