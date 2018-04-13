start_local_db:
	pg_ctl -D /usr/local/var/postgres start

process_sql:
	go run ./generate_sql/main.go

import_sql: process_sql
	psql gopher_search_development < ./database.sql

build:
	CGO_ENABLED=0 GOOS=linux buffalo build

vault:
	vault server -dev -dev-root-token-id=root123

run:
	go run main.go

consul-template:
	consul-template -config=config/config.hcl \
		-template "config/database.yml.tmpl:database.yml" \
	  -template "config/certificate.pem.tmpl:certs/cert.pem" \
	  -template "config/key.pem.tmpl:certs/key.pem" 
