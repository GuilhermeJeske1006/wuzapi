#!/bin/sh
set -eu

# Refuse SQLite fallback on Cloud's ephemeral filesystem.
: "${DB_HOST:?Configure PostgreSQL DB_HOST}"
: "${DB_PORT:?Configure PostgreSQL DB_PORT}"
: "${DB_USER:?Configure PostgreSQL DB_USER}"
: "${DB_PASSWORD:?Configure PostgreSQL DB_PASSWORD}"
: "${DB_NAME:?Configure PostgreSQL DB_NAME}"
: "${DB_SSLMODE:?Configure DB_SSLMODE (require for Cloud Postgres)}"
: "${WUZAPI_ADMIN_TOKEN:?Configure WUZAPI_ADMIN_TOKEN}"
: "${WUZAPI_GLOBAL_ENCRYPTION_KEY:?Configure a persistent 32-byte encryption key}"

if [ "${#WUZAPI_GLOBAL_ENCRYPTION_KEY}" -ne 32 ]; then
    echo 'WUZAPI_GLOBAL_ENCRYPTION_KEY must contain 32 ASCII bytes.' >&2
    exit 1
fi

# An empty address produces :PORT, listening on IPv4 and IPv6 for Cloud probes.
unset WUZAPI_ADDRESS WUZAPI_PORT
exec ./app --address= --port="${PORT:-3000}" --logtype=json --color=false
