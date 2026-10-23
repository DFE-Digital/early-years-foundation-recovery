#!/usr/bin/env bash
set -euo pipefail

: "${RESOURCE_GROUP:?}" "${REVIEWAPP_NAME:?}" "${PR_NUMBER:?}" "${RESOURCE_NAME_PREFIX:?}"
: "${DOCKER_IMAGE:?}" "${IMAGE_SHA:?}" "${PSQLFS_USERNAME:?}" "${PSQLFS_PASSWORD:?}"
: "${REVIEW_APP_SUBNET:?}" "${AZURE_VNET:?}"
[[ "$PR_NUMBER" =~ ^pr-[0-9]+$ ]] || { echo "Invalid PR_NUMBER" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -f "$tmp/key.pem" "$tmp/settings.json" "$tmp/container.json"; rmdir "$tmp"' EXIT
common=(--resource-group "$RESOURCE_GROUP" --name "$REVIEWAPP_NAME")
slot=("${common[@]}" --slot "$PR_NUMBER")
base_url="https://${REVIEWAPP_NAME}-${PR_NUMBER}.azurewebsites.net"
client_id="review-${PR_NUMBER}"
api_version=2024-11-01

plan_id="$(az webapp show "${common[@]}" --query serverFarmId -o tsv)"
capacity="$(az appservice plan show --ids "$plan_id" --query sku.capacity -o tsv)"
if [ "$capacity" != "1" ]; then
  echo "Review sidecars require a single-instance plan: simulator authorization codes are held in memory" >&2
  exit 1
fi

slots="$(az webapp deployment slot list "${common[@]}" --query '[].name' -o tsv | sed 's|.*/||')"
if ! grep -Fxq "$PR_NUMBER" <<<"$slots"; then
  # Start with the proxy, never Rails with a copied parent database URL.
  az webapp deployment slot create "${slot[@]}" \
    --configuration-source "$REVIEWAPP_NAME" \
    --deployment-container-image-name "${DOCKER_IMAGE}:review-proxy-${IMAGE_SHA}" --output none
fi
az webapp stop "${slot[@]}"
az postgres flexible-server db create --resource-group "$RESOURCE_GROUP" \
  --server-name "${RESOURCE_NAME_PREFIX}-psqlfs" --database-name "$PR_NUMBER" --output none

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$tmp/key.pem"
private_key="$(cat "$tmp/key.pem")"
public_key="$(openssl pkey -in "$tmp/key.pem" -pubout)"
# Mask every line before passing the key to subsequent commands.
while IFS= read -r line; do echo "::add-mask::$line"; done <<<"$private_key"
export private_key
export REVIEW_DATABASE_URL
REVIEW_DATABASE_URL="$(jq -nr --arg user "$PSQLFS_USERNAME" --arg password "$PSQLFS_PASSWORD" \
  --arg host "${RESOURCE_NAME_PREFIX}-psqlfs.postgres.database.azure.com" --arg db "$PR_NUMBER" \
  '"postgresql://\($user|@uri):\($password|@uri)@\($host)/\($db)?sslmode=require"')"
jq -n --arg domain "${base_url#https://}" --arg client "$client_id" \
  '{DATABASE_URL: env.REVIEW_DATABASE_URL, DOMAIN: $domain, REVIEW_APP: "true",
    GOV_ONE_PRIVATE_KEY: env.private_key, GOV_ONE_CLIENT_ID: $client,
    ENVIRONMENT: "development", RAILS_ENV: "production", PORT: "3000",
    DASHBOARD_UPDATE: "false", MAINTENANCE: "false",
    WEBSITES_CONTAINER_START_TIME_LIMIT: "720"}' >"$tmp/settings.json"
az webapp config appsettings set "${slot[@]}" --slot-settings @"$tmp/settings.json" --output none
unset private_key REVIEW_DATABASE_URL
az webapp vnet-integration add "${slot[@]}" --subnet "$REVIEW_APP_SUBNET" --vnet "$AZURE_VNET" --output none
az webapp config set "${slot[@]}" --linux-fx-version sitecontainers --output none
slot_id="$(az webapp show "${slot[@]}" --query id -o tsv)"

put_container() {
  az rest --method put \
    --url "https://management.azure.com${slot_id}/sitecontainers/$1?api-version=${api_version}" \
    --body @"$tmp/container.json" --output none
}

jq -n --arg image "${DOCKER_IMAGE}:${IMAGE_SHA}" \
  '{properties: {image: $image, isMain: false, targetPort: "3000", authType: "Anonymous"}}' >"$tmp/container.json"
put_container rails
jq -n --arg url "$base_url" --arg client "$client_id" --arg key "$public_key" \
  '{properties: {image: "ghcr.io/govuk-one-login/simulator:26.10.8", isMain: false,
    targetPort: "4000", authType: "Anonymous", environmentVariables: [
      {name: "PORT", value: "4000"}, {name: "SIMULATOR_URL", value: $url},
      {name: "CLIENT_ID", value: $client}, {name: "PUBLIC_KEY", value: $key},
      {name: "REDIRECT_URLS", value: ($url + "/users/auth/openid_connect/callback")},
      {name: "POST_LOGOUT_REDIRECT_URLS", value: ($url + "/users/sign_out")},
      {name: "SCOPES", value: "openid,email"}, {name: "ID_TOKEN_SIGNING_ALGORITHM", value: "ES256"},
      {name: "INTERACTIVE_MODE", value: "true"},
      {name: "EMAIL", value: ($client + "@example.com")}, {name: "SUB", value: $client}
    ]}}' >"$tmp/container.json"
put_container simulator
jq -n --arg image "${DOCKER_IMAGE}:review-proxy-${IMAGE_SHA}" \
  '{properties: {image: $image, isMain: true, targetPort: "8080", authType: "Anonymous"}}' >"$tmp/container.json"
put_container proxy
az webapp start "${slot[@]}"
