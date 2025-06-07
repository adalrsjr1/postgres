#!/bin/bash

set -ex

if [[ -z "$POSTGRES_USER" ]] ; then
    echo "POSTGRES_USER is unset"
    exit
fi

mkdir -p "${POSTGRES_USER}"
cd "${POSTGRES_USER}"
openssl req -new -nodes -out client.csr -keyout client.key -subj "/CN=$POSTGRES_USER" # authenticated user
openssl x509 -req -in client.csr -CA ../certs/server.crt -CAkey ../certs/server.key -out client.crt -days 3650 -CAcreateserial
chmod 600 client.key
rm client.csr
# docker exec -it postgres psql -c "DROP USER IF EXISTS ${POSTGRES_USER}"
docker exec -it postgres psql -c "CREATE USER ${POSTGRES_USER}"
