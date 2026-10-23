#!/usr/bin/env bash
set -euo pipefail

: "${RESOURCE_GROUP:?}" "${REVIEWAPP_NAME:?}" "${PR_NUMBER:?}" "${RESOURCE_NAME_PREFIX:?}"
[[ "$PR_NUMBER" =~ ^pr-[0-9]+$ ]] || { echo "Invalid PR_NUMBER" >&2; exit 1; }

slots="$(az webapp deployment slot list --resource-group "$RESOURCE_GROUP" \
  --name "$REVIEWAPP_NAME" --query '[].name' -o tsv | sed 's|.*/||')"
if grep -Fxq "$PR_NUMBER" <<<"$slots"; then
  az webapp deployment slot delete --resource-group "$RESOURCE_GROUP" \
    --name "$REVIEWAPP_NAME" --slot "$PR_NUMBER"
fi
databases="$(az postgres flexible-server db list --resource-group "$RESOURCE_GROUP" \
  --server-name "${RESOURCE_NAME_PREFIX}-psqlfs" --query '[].name' -o tsv)"
if grep -Fxq "$PR_NUMBER" <<<"$databases"; then
  az postgres flexible-server db delete --resource-group "$RESOURCE_GROUP" \
    --server-name "${RESOURCE_NAME_PREFIX}-psqlfs" --database-name "$PR_NUMBER" --yes
fi
