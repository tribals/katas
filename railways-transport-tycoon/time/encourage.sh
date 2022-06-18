#!/bin/dash

set -o errexit
set -o nounset
set -o monitor

PGDATA="$(mktemp -d)"
export PGDATA

export PGHOST='@/tmp'

initdb
postgres -k "${PGHOST}" >postgres.log 2>&1 &
sleep 2  # HACK

createdb "${USER}"
exec psql --echo-all --file=src/kata.sql --file -
