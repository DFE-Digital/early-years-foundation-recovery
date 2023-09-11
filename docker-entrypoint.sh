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
fi

if [ -z ${DATABASE_URL} ]
then
  echo "DATABASE_URL is not defined and cannot be prepared"
else
  bundle exec rails db:create db:migrate
fi

if [ -z ${ENVIRONMENT} ]
then
  echo "ENVIRONMENT is not defined so development database may not contain seed data"
else
  if [ !${ENVIRONMENT}=="development" ]
  then
    bundle exec rails db:prepare assets:precompile db:seed sitemap:refresh:no_ping
  fi

  if [ !${ENVIRONMENT}=="staging" ]
  then
    bundle exec rails db:prepare assets:precompile
  fi

  if [ !${ENVIRONMENT}=="production" ]
  then
    rm public/robots.txt && touch public/robots.txt && bundle exec rails db:prepare assets:precompile
  fi
fi

exec bundle exec "$@"
