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
  /usr/sbin/sshd

  if [ -z ${ENVIRONMENT} ]
  then
    echo "ENVIRONMENT is not defined"
  else
    bundle exec rails db:prepare

    case ${ENVIRONMENT} in
      "review" )
        bundle exec rails db:seed
        ;;
      "development" )
        bundle exec rails sitemap:refresh:no_ping
        ;;
      "staging" )
        # no op
        ;;
      "production" )
        rm public/robots.txt
        touch public/robots.txt
        ;;
      * )
        echo "ENVIRONMENT ${ENVIRONMENT} is not defined"
    esac
  fi

# ------------------------------------------------------------------------------
fi

exec bundle exec "$@"
