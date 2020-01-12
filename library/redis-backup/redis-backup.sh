#!/usr/bin/env bash

set -o nounset
set -o errexit

REDIS_HOST=${REDIS_HOST:-localhost}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_DIR=${REDIS_DIR:-/data/redis}
REDIS_BGSAVE_WAIT=${REDIS_BGSAVE_WAIT:-30}
BACKUP_DIR=${BACKUP_DIR:-/data/backup}

echo "Redis backup started at $(date -Iseconds)"
TIMESTAMP_BEFORE_BGSAVE=$(redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw LASTSAVE)
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw BGSAVE

echo "Waiting for ${REDIS_BGSAVE_WAIT} seconds..."
REDIS_BGSAVE_WAIT_PAST=0
while [[ "${REDIS_BGSAVE_WAIT}" -gt "${REDIS_BGSAVE_WAIT_PAST}" ]]
do
    TIMESTAMP_LASTSAVE=$(redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw LASTSAVE)
    if [[ "${TIMESTAMP_LASTSAVE}" -eq "${TIMESTAMP_BEFORE_BGSAVE}" ]]
    then
        echo "Wait for 1 second - ${REDIS_BGSAVE_WAIT_PAST}..."
        sleep 1
    else
        echo "LASTSAVE changed (now ${TIMESTAMP_LASTSAVE}, was ${TIMESTAMP_BEFORE_BGSAVE}), breaking wait loop..."
        break
    fi
    REDIS_BGSAVE_WAIT_PAST=$((REDIS_BGSAVE_WAIT_PAST + 1))
done

rsync -ahvz --stats --delete-after ${REDIS_DIR}/* ${BACKUP_DIR}
find ${BACKUP_DIR} -mtime +7 -print0 | xargs -r -0 rm

echo "Redis backups ended at $(date -Iseconds)"

exit 0
