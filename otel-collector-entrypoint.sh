#!/bin/sh

set -eu

if [ -n "${SPLUNK_REALM:-}" ] && [ -n "${SPLUNK_ACCESS_TOKEN:-}" ]; then
  config=/etc/otel-collector-config.yml
else
  config=/etc/otel-collector-azure-config.yml
fi

exec otelcol --config="$config" "$@"
