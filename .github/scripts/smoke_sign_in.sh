#!/usr/bin/env bash
set -euo pipefail

base_url="${1:?Usage: smoke_sign_in.sh <base_url>}"
base_url="${base_url%/}"
mode="${2:-live}"
if [ "$mode" != live ] && [ "$mode" != review ]; then
  echo "Unknown smoke check mode: $mode" >&2
  exit 1
fi

health_url="${base_url}/health"
sign_in_url="${base_url}/users/sign-in"

max_attempts=30
sleep_seconds=10

echo "Running smoke checks against ${base_url}"

for attempt in $(seq 1 "${max_attempts}"); do
  echo "Waiting for health endpoint (${attempt}/${max_attempts})"
  if curl --silent --show-error --fail --location --max-time 20 "${health_url}" >/dev/null; then
    echo "Health endpoint is available"
    break
  fi

  if [ "${attempt}" -eq "${max_attempts}" ]; then
    echo "Health endpoint did not become available: ${health_url}" >&2
    exit 1
  fi

  sleep "${sleep_seconds}"
done

for attempt in $(seq 1 "${max_attempts}"); do
  echo "Waiting for sign-in page (${attempt}/${max_attempts})"

  if page="$(curl --silent --show-error --fail --location --max-time 20 "${sign_in_url}")"; then
    if grep -q "Continue to GOV.UK One Login" <<<"${page}"; then
      echo "Sign-in page includes GOV.UK One Login CTA"

      if [ "$mode" = review ]; then
        printf '%s' "$page" | ruby "$(dirname "$0")/check_review_sign_in.rb" "$base_url"
        status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --max-time 20 "${base_url}/config")"
        if [ "$status" != 404 ]; then
          echo "Simulator configuration API must return 404, got $status" >&2
          exit 1
        fi
        echo "Review sign-in link is valid and simulator configuration API is blocked"
        exit 0
      fi

      if ! grep -Eq 'href="https://[^"]*account\.gov\.uk[^"]*"' <<<"${page}"; then
        echo "GOV.UK One Login account.gov.uk link not found" >&2
        exit 1
      fi

      # Ensure generated auth link still has core OIDC query params.
      if ! grep -Eq 'href="https://[^"]*/authorize\?[^"]*client_id=[^"]*"' <<<"${page}"; then
        echo "Sign-in authorize link missing client_id" >&2
        exit 1
      fi

      if ! grep -Eq 'href="https://[^"]*/authorize\?[^"]*redirect_uri=[^"]*"' <<<"${page}"; then
        echo "Sign-in authorize link missing redirect_uri" >&2
        exit 1
      fi

      if ! grep -Eq 'href="https://[^"]*/authorize\?[^"]*response_type=code[^"]*"' <<<"${page}"; then
        echo "Sign-in authorize link missing response_type=code" >&2
        exit 1
      fi

      echo "Sign-in page includes valid GOV.UK One Login authorize link"
      exit 0
    fi
  fi

  if [ "${attempt}" -eq "${max_attempts}" ]; then
    echo "Sign-in smoke checks failed: ${sign_in_url}" >&2
    exit 1
  fi

  sleep "${sleep_seconds}"
done
