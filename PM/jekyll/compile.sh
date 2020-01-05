#!/bin/sh -e

ORIGIN=/origin
DESTINATION=/destination

for arg in "$@"
do
    case $arg in
        -*)
            echo "Invalid option: -$OPTARG"
            echo "usage: $0 [<SHA1>]"
            echo "    SHA1: SHA1 to build (optional)"
            exit 1
        ;;
        *)
            if ! [ -z "$1" ]; then
                SHA1=$1
            fi
        ;;
    esac
    if [ "0" -lt "$#" ]; then
        shift
    fi
done

if [ -z "$SHA1" ]; then
    SHA1=master
fi

git clone $ORIGIN/.
git checkout $SHA1

# Compilation /james-project/src/jekyll/_site
jekyll build --source src/homepage --destination $DESTINATION
