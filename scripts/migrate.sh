#!/bin/sh
# ---------------------------
set -e

echo $CONTENTFUL_SPACE
echo $CONTENTFUL_MANAGEMENT_TOKEN
echo $CONTENTFUL_ENVIRONMENT
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE -e $CONTENTFUL_ENVIRONMENT scripts/migrations/01-create-static.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE -e $CONTENTFUL_ENVIRONMENT scripts/migrations/02-add-footer-checkbox-to-static.js
