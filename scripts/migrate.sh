#!/bin/sh
# ---------------------------
set -e

echo $CONTENTFUL_SPACE
echo $CONTENTFUL_MANAGEMENT_TOKEN
echo $CONTENTFUL_ENVIRONMENT
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE -e $CONTENTFUL_ENVIRONMENT scripts/migrations/01-create-page.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE -e $CONTENTFUL_ENVIRONMENT scripts/migrations/02-create-question.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE -e $CONTENTFUL_ENVIRONMENT scripts/migrations/03-create-video.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE -e $CONTENTFUL_ENVIRONMENT scripts/migrations/04-create-training-module.js
