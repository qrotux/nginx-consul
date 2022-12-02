# Environment

`CONSUL` - address of consul server (ex: `consul:8500`)
`CONSUL_AUTH` - Basic auth to Consul server (ex: `user:password`)
`CONSUL_TOKEN` - Consul ACL access token to directory (ex: `********-****-****-****-************`)
`CONSUL_PREFIX` - directory prefix of used keys (ex: `/services/nginx`)

# Keys

`${CONSUL_PREFIX}/{file}.conf` > `/etc/nginx/{file}.conf`
`${CONSUL_PREFIX}/{file}.inc` > `/etc/nginx/{file}.inc`

`${CONSUL_PREFIX}/conf.d/{file}.conf` -> `/etc/nginx/conf.d/{file}.conf`
`${CONSUL_PREFIX}/stream.d/{file}.conf` -> `/etc/nginx/stream.d/{file}.conf`

`${CONSUL_PREFIX}/{service}/ssl/crt` -> `/etc/nginx/ssl/{service}/server.crt`
`${CONSUL_PREFIX}/{service}/ssl/key` -> `/etc/nginx/ssl/{service}/server.key`

`${CONSUL_PREFIX}/{service}/restrict` -> `/etc/nginx/keys/{service}.htpasswd`
`${CONSUL_PREFIX}/{service}/restrict-users/{user} : {password}` -> `/etc/nginx/keys/{service}.htpasswd`
