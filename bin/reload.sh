#!/bin/bash

if [ -f "/usr/local/bin/nginx-keys.sh" ]; then
  chmod +x /usr/local/bin/nginx-keys.sh
  bash -c "/usr/local/bin/nginx-keys.sh"
fi

while [ ! -f "/var/run/nginx.pid" ] || [ ! -f "/.consul-ready" ]; do
  echo "Await nginx running" 1>&2
  sleep 1
done

rm /.consul-ready

CONFIG_TEST=$(nginx -t 2>/dev/stdout | grep "test is successful" | wc -l)

if [ "${CONFIG_TEST}" = 0 ]; then
  echo "Nginx config is invalid, do nothing..." 1>&2
else
  echo "Nginx config is valid, reloading..." 1>&2
  nginx -s reload &
fi
