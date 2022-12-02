#!/bin/bash

mkdir -p /etc/nginx/stream.d 1>&2

has_config=0

if [[ -d "${DATA_DIR}" ]] && [[ -f "${DATA_DIR}/nginx.conf" ]]; then
  has_config=1
  cp -r ${DATA_DIR}/* /etc/nginx/ 1>&2 /dev/null
fi

if [[ -n ${CONSUL} ]] && [[ "${CONSUL}" != "" ]]; then
  CONSUL_ARGS="-consul-addr=${CONSUL}"

  if [ "${CONSUL_SSL}" == "true" ]; then
    CONSUL_ARGS="${CONSUL_ARGS} -consul-ssl"
  fi

  if [ "${CONSUL_AUTH}" ]; then
    CONSUL_ARGS="${CONSUL_ARGS} -consul-auth=${CONSUL_AUTH}"
  fi

  if [ "${CONSUL_TOKEN}" ]; then
    CONSUL_ARGS="${CONSUL_ARGS} -consul-token=${CONSUL_TOKEN}"
  fi

  CONSUL_ARGS="${CONSUL_ARGS} -config=${CONSUL_TEMPLATE_CONFIG}"

  if [ "${has_config}" == "0" ]; then
    cp /etc/nginx/nginx.conf.source /etc/nginx/nginx.conf 2>/dev/null
  fi

  consul-template ${CONSUL_ARGS} &
  echo "Listening for consul changes" 1>&2

  if [ "${has_config}" == "0" ]; then
    while [ ! -f "/.consul-ready" ]; do
      echo "Waiting for consul execution" 1>&2
      sleep 1
    done
  fi
else
  cp /etc/nginx/nginx.conf.source /etc/nginx/nginx.conf 2>/dev/null
fi


if [ "${CONF}" ]; then
  echo "${CONF}" > /etc/nginx/conf.d/default.conf
fi

if [ "${STREAM}" ]; then
  echo "${STREAM}" > /etc/nginx/stream.d/default.conf
fi

echo "Run nginx" 1>&2
exec nginx -g 'daemon off;'
