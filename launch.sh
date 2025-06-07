#!/bin/bash

set -ex

if [[ -z "$POSTGRES_USER" ]]; then
    echo 'expected POSTGRES_USER="$(whoami)"'
    exit
fi

PGIMAGE="${PGIMAGE:-postgres:16-bookworm}"
PGCONTAINER="${PGCONTAINER:-postgres}"

POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-secret}"
POSTGRES_DB="${POSTGRES_DB:-$POSTGRES_USER}"
POSTGRES_INITDB_ARGS=""
POSTGRES_HOST_AUTH_METHOD="${POSTGRES_HOST_AUTH_METHOD:-cert}"
PGDATAFOLDER="/var/lib/postgresql/data"
PGDATA="$PGDATAFOLDER/pgdata"

HOSTDATAFOLDER="${HOSTDATAFOLDER:-$PWD/pgdata}"
CERTS="$PWD/certs"

# Create directories if they don't exist
mkdir -p "$HOSTDATAFOLDER" "$CERTS"

# Generate certificates for server and root if they don't exist
if [ ! -f "$CERTS/server.key" ]; then
    cd "$CERTS"
    openssl req -new -x509 -nodes -out server.crt -keyout server.key -days 3650 -subj "/CN=${PGCONTAINER}.local" -addext "subjectAltName = IP:172.17.0.2, DNS:${PGCONTAINER}.local"
    openssl req -new -nodes -out client.csr -keyout client.key -subj "/CN=$POSTGRES_USER" # authenticated user
    openssl x509 -req -in client.csr -CA server.crt -CAkey server.key -out client.crt -days 3650 -CAcreateserial
    chmod 600 server.key client.key
    rm *.csr *.srl
    cd ..
    echo "root certs (client.*) created at '$CERTS' folder"
fi

docker run -it \
    --name "$PGCONTAINER" \
    --rm \
    --user "$(id -u):$(id -g)" \
    -v /etc/passwd:/etc/passwd:ro \
    -v "$HOSTDATAFOLDER:$PGDATAFOLDER" \
    -v "$CERTS:/usr/local/share/certs" \
    -v "$PWD/my-postgres.conf:/etc/postgresql/postgresql.conf" \
    -v "$PWD/my-pg_hba.conf:/etc/postgresql/pg_hba.conf" \
    -e POSTGRES_HOST_AUTH_METHOD="$POSTGRES_HOST_AUTH_METHOD" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -p 0.0.0.0:5432:5432 \
    "$PGIMAGE" \
    -c 'config_file=/etc/postgresql/postgresql.conf' \
    -c 'hba_file=/etc/postgresql/pg_hba.conf' 

