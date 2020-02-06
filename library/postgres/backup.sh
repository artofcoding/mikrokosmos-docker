#!/bin/sh

#pg_dumpall >pg_backup.bak

DATABASE=${1:-psql}
pg_dump "${DATABASE}" >"${DATABASE}.sql"

exit 0
