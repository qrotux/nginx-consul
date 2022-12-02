template {
	source = "/etc/consul-template/nginx-keys.ctmpl"
	destination = "/usr/local/bin/nginx-keys.sh"
	command = "reload.sh"
}