#!/bin/sh
# ---------------------------
set -e

contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE scripts/migrations/01-create-page.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE scripts/migrations/02-create-question.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE scripts/migrations/03-create-video.js
contentful space migration --mt $CONTENTFUL_MANAGEMENT_TOKEN --space-id $CONTENTFUL_SPACE scripts/migrations/04-create-training-module.js