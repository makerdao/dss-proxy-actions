#! /usr/bin/env bash

set -e

function message() {
    echo
    echo -----------------------------------
    echo "$@"
    echo -----------------------------------
    echo
}

message BUILDING DOCKER IMAGE
docker build -t makerdao/dss-proxy-actions-test .

message RUNNING TESTS
docker run --rm -it makerdao/dss-proxy-actions-test

