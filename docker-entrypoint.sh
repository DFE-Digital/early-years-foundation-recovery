#!/bin/sh
# ------------------------------------------------------------------------------
set -e

if [ !${RAILS_ENV}=="production" ]
then

  if [ -z ${PROXY_CERT} ]
  then
    echo "No proxy certificate to append"
  else
    echo "Appending proxy certificate"
    cat $PROXY_CERT >> /etc/ssl/certs/ca-certificates.crt
  fi

#
# Development & Test
#
# ------------------------------------------------------------------------------
  if bundle check
  then
    echo "$RAILS_ENV gems already bundled"
  else
    bundle
  fi

  if [ ! -d "node_modules" ]
  then
    bundle exec rails yarn:install
  fi

  if [ -z ${DATABASE_URL} ]
  then
    echo "DATABASE_URL is not defined and cannot be prepared"
  else
    bundle exec rails db:create db:migrate
  fi

  rm -f tmp/pids/server.pid

# ------------------------------------------------------------------------------
else

#
# Production
#
# ------------------------------------------------------------------------------
  if [ -z ${ENVIRONMENT} ]
  then
    echo "ENVIRONMENT is not defined"
  else
    /usr/sbin/sshd

    case ${ENVIRONMENT} in
      "review" )
        # bundle exec rails db:prepare assets:precompile db:seed
        bundle exec rails db:prepare db:seed
        ;;
      "development" )
        # bundle exec rails db:prepare assets:precompile sitemap:refresh:no_ping
        bundle exec rails db:prepare sitemap:refresh:no_ping
        ;;
      "staging" )
        # bundle exec rails db:prepare assets:precompile
        bundle exec rails db:prepare
        ;;
      "production" )
        rm public/robots.txt
        touch public/robots.txt
        # bundle exec rails db:prepare assets:precompile
        bundle exec rails db:prepare
        ;;
      * )
        echo "ENVIRONMENT ${ENVIRONMENT} is not defined"
    esac
  fi

# ------------------------------------------------------------------------------
fi

exec bundle exec "$@"
