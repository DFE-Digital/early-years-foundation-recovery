#!/bin/sh
# ------------------------------------------------------------------------------
set -e

sed -i "s/foo/${BOT}/g" /usr/config.json

if [ ! -z "$1" ]; then
  echo "Sitemap using: $1"

  exec pa11y-ci \
      --config /usr/config.json \
      --sitemap http://${DOMAIN}/sitemap.xml \
      --sitemap-find http://${DOMAIN} \
      --sitemap-replace ${1}
else
  exec pa11y-ci \
      --config /usr/config.json \
      --sitemap http://${DOMAIN}/sitemap.xml
fi
