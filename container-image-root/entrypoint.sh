#!/bin/bash
set -x

[ "$IP" == "" ] && IP=$(curl ifconfig.co/ip -s)

service ntp start
curl -s https://core.telegram.org/getProxySecret -o /srv/MTProxy/objs/bin/proxy-secret > /dev/null 2>&1
curl -s https://core.telegram.org/getProxyConfig -o /srv/MTProxy/objs/bin/proxy-multi.conf > /dev/null 2>&1
cron

if [ "$1" == "" ];
then
./mtproto-proxy -u nobody -p 8888 -H 8889 -S $SECRET -c $MAX_CONNECTIONS --aes-pwd proxy-secret proxy-multi.conf -M $WORKERS --nat-info $(hostname --ip-address):$IP --http-stats
else
exec "$1"
fi
