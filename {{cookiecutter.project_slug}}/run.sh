#!/usr/bin/env bash

set -eo pipefail

DC="${DC:-exec}"

# If we're running in CI we need to disable TTY allocation for docker-compose
# commands that enable it by default, such as exec and run.
TTY=""
if [[ ! -t 1 ]]; then
  TTY="-T"
fi

# -----------------------------------------------------------------------------
# Helper functions start with _ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

function _dc {
  docker-compose "${DC}" ${TTY} "${@}"
}

function _build_run_down {
  docker-compose build
  docker-compose run ${TTY} "${@}"
  docker-compose down
}

# -----------------------------------------------------------------------------

function cmd {
  # Run any command you want in the backend container
  _dc backend "${@}"
}

function manage {
  # Run any manage.py commands

  # We need to collectstatic before we run our tests.
  if [ "${1-''}" == "test" ]; then
    cmd python3 manage.py collectstatic --no-input
  fi

  cmd python3 manage.py "${@}"
}

function secret {
  # Generate a random secret that can be used for your SECRET_KEY and more
  cmd python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
}

function shell {
  # Start a shell session in the backend container
  cmd bash "${@}"
}

function psql {
  # Connect to PostgreSQL
  # shellcheck disable=SC1091
  . .env
 _dc postgres psql -U "${POSTGRES_USER}" "${@}"
}


function help {
  printf "%s <task> [args]\n\nTasks:\n" "${0}"

  compgen -A function | grep -v "^_" | cat -n

  printf "\nExtended help:\n  Each task has comments for general usage\n"
}

# This idea is heavily inspired by: https://github.com/adriancooney/Taskfile
TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:-help}"