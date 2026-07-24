#!/usr/bin/env bash
set -euo pipefail

base_url="${1:?Usage: smoke_sign_in.sh <base_url>}"
base_url="${base_url%/}"

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
