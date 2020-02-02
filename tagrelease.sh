#!/bin/sh

set -o nounset
set -o errexit

if [ $# -eq 0 ]
then
    echo "usage: $0 <tag>"
    exit 1
fi

TAG=$1

git tag -d "${TAG}"
git push origin :refs/tags/"${TAG}"
git tag -f "${TAG}"
git push --tags origin HEAD

exit 0
