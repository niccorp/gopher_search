#!/bin/bash -e

sudo apt-get update
sudo apt-get install -y postgresql-client

wget -O database.sql https://github.com/nicholasjackson/gopher_search/releases/download/v0.1/database.sql

PGPASSWORD=$3 psql "sslmode=disable host=$1 port=5432 dbname=gopher_search_production" --username=$2 < ./database.sql
