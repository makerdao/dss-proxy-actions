#!/usr/bin/env bash
set -e

export DAPP_BUILD_OPTIMIZE=1
export DAPP_BUILD_OPTIMIZE_RUNS=200

if [[ -z "$1" ]]; then
    forge test -v --force --use 0.6.12 -vv
else
    forge test -v --force --use 0.6.12 --match "$1" -vvv
fi
