#!/bin/bash

export MATRIX_SERVER=
export MATRIX_ACCESS_TOKEN=
export MATRIX_ROOM_ID=

if test -z "${MATRIX_SERVER}"; then
    echo "ERROR: Environment variable MATRIX_SERVER is unset."
    exit 1
fi
if test -z "${MATRIX_ACCESS_TOKEN}"; then
    echo "ERROR: Environment variable MATRIX_ACCESS_TOKEN is unset."
    exit 1
fi
if test -z "${MATRIX_ROOM_ID}"; then
    echo "ERROR: Environment variable MATRIX_ROOM_ID is unset."
    exit 1
fi

exec /usr/local/bin/hcloud-uptime-alerter.sh