#!/bin/sh
# ------------------------------------------------------------------------------
set -e

if [ ! -z "$1" ]; then
  echo "Sitemap using: $1"
  SITE=$1
else
  SITE=$DOMAIN
fi

sed -i "s/foo/${BOT}/g" /usr/config.json

exec pa11y-ci \
      --config /usr/config.json \
      --sitemap ${DOMAIN}/sitemap.xml \
      --sitemap-find ${DOMAIN} \
      --sitemap-replace ${SITE}
