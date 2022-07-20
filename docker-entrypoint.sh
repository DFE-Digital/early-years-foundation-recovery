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
    # NB: Streaming console output as NDJSON was appended to fix an unidentified
    # quirk that was introduced with the puppeteer dependency
    yarn install --json
  fi

  rm -f tmp/pids/server.pid
fi

if [ -z ${DATABASE_URL} ]
then
  echo "DATABASE_URL is not defined and cannot be prepared"
else
  bundle exec rails db:prepare
fi

exec bundle exec "$@"
