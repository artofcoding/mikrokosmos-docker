#!/bin/sh

DATABASE=${1:-psql}
psql --set ON_ERROR_STOP=on ${DATABASE} <${DATABASE}.sql

exit 0
