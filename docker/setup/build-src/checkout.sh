#!/bin/bash

#####################
# Script: checkout.sh
# Checkout out a branch in an already cloned core repo
#
# $1: build_source: build type: only two options: COMMIT or TAG
# $2: build_id: branch or commit to check out

set -e

build_source=$1
build_id=$2
echo "Build source: $build_source"
echo "Build id: $build_id"

# Checks out by commit/branch
#
# $1: commit or branch
function build_by_commit {
    mkdir -p /build/src && cd /build/src

    echo "Building from source commit: $1"
    cd /build/src/core
    git clean -f -d
    git pull
    git checkout "$1"
}

case "${build_source}" in
    "COMMIT" | "TAG" )
        build_by_commit "${build_id}"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
