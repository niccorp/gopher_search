start_local_db:
	pg_ctl -D /usr/local/var/postgres start

process_sql:
	go run ./generate_sql/main.go

import_sql: process_sql
	psql gopher_search_development < ./database.sql

build:
	CGO_ENABLED=0 GOOS=linux buffalo build
