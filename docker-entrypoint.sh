#!/bin/sh
# ------------------------------------------------------------------------------
set -e

if [ !${RAILS_ENV}=="production" ]
then
  if bundle check
  then
    echo "$RAILS_ENV gems already bundled"
  else
    bundle
  fi

  if [ ! -d "node_modules" ]; then
    yarn
  fi

  rm -f tmp/pids/server.pid
fi

if [ -z ${DATABASE_URL} ]
then
  echo "$DATABASE_URL is not defined, skipping database setup"
else
  bundle exec rake db:prepare
fi

exec bundle exec "$@"
