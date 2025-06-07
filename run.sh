#!/bin/bash

POSTGRES_DB="${POSTGRES_DB:-postgres}"
POSTGRES_HOST="postgres.local"
CERTS="${CERTS:-certs}" # default to certs for root access, user specific certs for the newly created users

if [[ -z "$POSTGRES_USER" ]] ; then
    echo ' expected POSTGRES_USER=$(whoami) ./run.sh'
    exit
fi

psql "host=${POSTGRES_HOST} \
      dbname=postgres \
      user=${POSTGRES_USER} \
      sslmode=verify-full \
      sslcert=${CERTS}/client.crt \
      sslkey=${CERTS}/client.key \
      sslrootcert=certs/server.crt"
