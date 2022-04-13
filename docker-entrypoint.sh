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
  echo "DATABASE_URL is not defined and cannot be prepared"
else
  bundle exec rails db:prepare
fi

if [ -z ${DEMO_USER_PASSWORD} ]
then
  echo "DEMO_USER_PASSWORD is not defined, database will not be seeded"
else
  bundle exec rails db:seed
fi

exec bundle exec "$@"
