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
    bundle exec rails yarn:install
  fi

  rm -f tmp/pids/server.pid
else
  if [ ${WORKSPACE} = "production" ]
  then
    mv public/robots-allow-crawlers.txt public/robots.txt
  else
    mv public/robots-block-crawlers.txt public/robots.txt
  fi
fi

if [ -z ${DATABASE_URL} ]
then
  echo "DATABASE_URL is not defined and cannot be prepared"
else
  bundle exec rails db:prepare
fi

exec bundle exec "$@"
