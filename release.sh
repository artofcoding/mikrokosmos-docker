#!/usr/bin/env bash
#
# Copyright (C) 2020 art of coding UG, https://www.art-of-coding.eu
# Alle Rechte vorbehalten. Nutzung unterliegt Lizenzbedingungen.
# All rights reserved. Use is subject to license terms.
#

set -o nounset
set -o errexit

function show_usage() {
    echo "usage: $0 -t <tag> [-c <commit>] [-p]"
    echo "   -t    Tag for release, e.g. v1.0.0"
    echo "   -c    Commit SHA"
    echo "   -p    push to origin"
    echo
    echo "The following tags are the last 10:"
    git --no-pager tag -l -n1 --sort=-v:refname | head -10
    exit 1
}

function done_or_failed() {
    local ret=$1
    if [[ ${ret} -eq 0 ]]
    then
        echo " done"
    else
        echo " failed"
        exit 1
    fi
}

if [[ ! -x "$(command -v git)" ]]
then
    echo "No git found"
    exit 1
fi

PUSH_TO_ORIGIN="false"
while getopts t:c:p opt
do
   case "${opt}" in
       t) TAG="${OPTARG}" ;;
       c) COMMIT_SHA="${OPTARG}" ;;
       p) PUSH_TO_ORIGIN="true" ;;
       *)
           echo "Unknown option ${OPTARG}"
           show_usage
           exit 1
       ;;
   esac
done
# Release tag
if [[ -z "${TAG:-}" ]]
then
    echo "Missing tag, use -t"
    show_usage
fi
# Which commit?
[[ -z "${COMMIT_SHA:-}" ]] && COMMIT_SHA="$(git rev-parse --short HEAD)"
# Verify: we are on develop?
BRANCH="$(git branch --show-current)"
if [[ "${BRANCH}" == "" ]]
then
    echo "You are in detached HEAD state!"
    exit 1
fi
if [[ "${BRANCH}" != "develop" ]]
then
    echo "Not on develop"
    exit 1
fi

echo "Merging branch develop to master"
git push . develop:master
done_or_failed $?
if [[ $(git --no-pager tag -l | grep -c "${TAG}") -gt 0 ]]
then
    echo "Tag ${TAG} already exists"
    echo -n "Removing local tag ${TAG}..."
    git tag -d "${TAG}" || echo " ${TAG} does not exist,"
    done_or_failed $?
    echo -n "Removing tag ${TAG} at remote..."
    git push origin :refs/tags/"${TAG}"
    done_or_failed $?
fi
echo -n "Tagging commit ${COMMIT_SHA} as ${TAG}..."
git tag -f "${TAG}" "${COMMIT_SHA}"
done_or_failed $?

if [[ "${PUSH_TO_ORIGIN}" == "true" ]]
then
    echo -n "Pushing to origin/develop..."
    git push origin develop
    done_or_failed $?
    echo -n "Pushing to origin/master..."
    git push origin master
    done_or_failed $?
    echo -n "Puhsing tags to origin HEAD..."
    git push --tags origin HEAD
    done_or_failed $?
fi

exit 0
