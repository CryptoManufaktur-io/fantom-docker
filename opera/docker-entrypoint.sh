#!/bin/bash
set -Eeuo pipefail

GENESIS=/var/lib/opera/mainnet.g
if [[ ! -f "/var/lib/opera/setupdone" ]]; then
  if [[ -n "$GENESIS_FILE" ]]; then
    echo "Fetching genesis file for mainnet"
    wget -O "$GENESIS" "$GENESIS_FILE"
    touch /var/lib/opera/setupdone
    exec "$@" --genesis "$GENESIS"
  else
    echo "Genesis file not found. Please specify GENESIS_FILE in .env"
    echo "and then ./ethd restart"
    exit 0
  fi
fi

if [[ -f "/var/lib/opera/setupdone" && -f "$GENESIS" ]]; then
  echo "Removing processed Genesis file"
  rm "$GENESIS"
fi

# Set verbosity
shopt -s nocasematch
case ${LOG_LEVEL} in
  error)
    __verbosity="--verbosity 1"
    ;;
  warn)
    __verbosity="--verbosity 2"
    ;;
  info)
    __verbosity="--verbosity 3"
    ;;
  debug)
    __verbosity="--verbosity 4"
    ;;
  trace)
    __verbosity="--verbosity 5"
    ;;
  *)
    echo "LOG_LEVEL ${LOG_LEVEL} not recognized"
    __verbosity=""
    ;;
esac

if [ -f /var/lib/opera/prune-marker ]; then
  rm -f /var/lib/opera/prune-marker
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" snapshot prune-state
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__verbosity} ${OP_EXTRAS}
fi
