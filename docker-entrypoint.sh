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

  if [ -z ${PROXY_CERT} ]
  then
    echo "No proxy certificate to append"
  else
    echo "Appending proxy certificate"
    cat $PROXY_CERT >> /etc/ssl/certs/ca-certificates.crt
  fi
fi

if [ -z ${DATABASE_URL} ]
then
  echo "DATABASE_URL is not defined and cannot be prepared"
else
  bundle exec rails db:create db:migrate
fi

if [ -z ${ENVIRONMENT} ]
then
  echo "ENVIRONMENT is not defined so the app may not startup as intended"
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

/usr/sbin/sshd

exec bundle exec "$@"
