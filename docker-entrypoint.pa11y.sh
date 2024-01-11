#!/bin/sh
# ------------------------------------------------------------------------------
set -e

sed -i "s/token/${BOT_TOKEN}/g" /usr/config.json

echo "Sitemap using: ${1}"

exec pa11y-ci \
    --config /usr/config.json \
    --sitemap ${1}/sitemap.xml \
    --sitemap-find http://${DOMAIN} \
    --sitemap-replace ${1}
