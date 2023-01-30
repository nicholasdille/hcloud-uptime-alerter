#!/bin/bash

if test -z "${MATRIX_SERVER}"; then
    echo "ERROR: Environment variable MATRIX_SERVER is required."
    exit 1
fi
if test -z "${MATRIX_ACCESS_TOKEN}"; then
    echo "ERROR: Environment variable MATRIX_ACCESS_TOKEN is required."
    exit 1
fi
if test -z "${MATRIX_ROOM_ID}"; then
    echo "ERROR: Environment variable MATRIX_ROOM_ID is required."
    exit 1
fi

: "${BIRTH_FILE:=/var/log/cloud-init.log}"
: "${MAX_IDLE_SECONDS:=$(( 60 * 60 * 4 ))}"
: "${IGNORE_ACTIVE_USERS:=false}"

if ! test -f "${BIRTH_FILE}"; then
    echo "ERROR: Birth file <${BIRTH_FILE}> does not exist."
    exit 1
fi

NOW="$( date +%s )"
echo "Now is ${NOW}"

BIRTH_EPOCH="$( stat --format="%W" "${BIRTH_FILE}" )"
echo "System came alive at ${BIRTH_EPOCH}"

if ! ${IGNORE_ACTIVE_USERS} && test "$(w --no-header | wc -l)" -gt 0; then
    echo "WARNING: User(s) are currently logged in. System is not idle."
    exit
fi

LAST_LOGOUT_TIMESTAMP="$( grep " logged out." /var/log/auth.log | tail -n 1 | cut -d' ' -f1-3 )"
LAST_LOGOUT_EPOCH="$( date -d "${LAST_LOGOUT_TIMESTAMP}" +%s )"
echo "Last logout at ${LAST_LOGOUT_EPOCH}"

IDLE_SECONDS=$(( NOW - LAST_LOGOUT_EPOCH ))
echo "System idle for ${IDLE_SECONDS}"

if test "${IDLE_SECONDS}" -gt "${MAX_IDLE_SECONDS}"; then
    echo "System has been idle for too long"
    curl "https://${MATRIX_SERVER}/_matrix/client/r0/rooms/${MATRIX_ROOM_ID}/send/m.room.message?access_token=${MATRIX_ACCESS_TOKEN}" \
        --silent \
        --fail \
        --request POST \
        --data "{\"msgtype\":\"m.text\",\"body\":\"System <$(hostname)> has been idle for too long\"}"
fi