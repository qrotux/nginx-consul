ARG NGINX_VERSION=1.19.4
FROM nginx:${NGINX_VERSION}-alpine AS builder

ARG SRCACHE_VERSION=0.32
ARG MEMC_VERSION=0.19

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev

RUN mkdir -p /src && cd /src && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    tar -xzvf nginx.tar.gz && \
    wget "https://github.com/openresty/memc-nginx-module/archive/refs/tags/v${MEMC_VERSION}.tar.gz" -O memc.tar.gz && \
    tar -xzvf "memc.tar.gz" && \
    wget "https://github.com/openresty/srcache-nginx-module/archive/refs/tags/v${SRCACHE_VERSION}.tar.gz" -O srcache.tar.gz && \
    tar -xzvf "srcache.tar.gz"

WORKDIR /src/nginx-${NGINX_VERSION}
RUN NGINX_ARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    ./configure \
        --with-compat \
        --with-http_ssl_module \
        --add-dynamic-module="/src/memc-nginx-module-${MEMC_VERSION}" \
        --add-dynamic-module="/src/srcache-nginx-module-${SRCACHE_VERSION}" \
        ${NGINX_ARGS} && \
    make modules

FROM nginx:${NGINX_VERSION}-alpine

MAINTAINER Smolyaninov Ilya

RUN apk update && apk add tini bash openssl ca-certificates && rm -rf /var/cache/apk/*

COPY bin/* /bin/

RUN chmod +x /bin/*

COPY consul-template /etc/consul-template
COPY nginx/nginx.conf /etc/nginx/nginx.conf.source
COPY --from=builder /src/nginx-${NGINX_VERSION}/objs/ngx_http_memc_module.so /src/nginx-${NGINX_VERSION}/objs/ngx_http_srcache_filter_module.so /usr/lib/nginx/modules/

ENV DATA_DIR="/data"
ENV CONSUL=""
ENV CONSUL_SSL="false"
ENV CONSUL_AUTH=""
ENV CONSUL_TOKEN=""
ENV CONSUL_TEMPLATE_CONFIG="/etc/consul-template/config.hcl"

ENTRYPOINT ["start.sh"]
