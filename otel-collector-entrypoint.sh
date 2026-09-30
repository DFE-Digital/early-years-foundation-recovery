#!/bin/sh

set -eu

if [ -n "${SPLUNK_REALM:-}" ] && [ -n "${SPLUNK_ACCESS_TOKEN:-}" ]; then
  config=/etc/otel-collector-config.yml
elif [ "${OTEL_COLLECTOR_LOCAL:-}" = "true" ]; then
  config=/etc/otel-collector-local-config.yml
else
  config=/etc/otel-collector-azure-config.yml
fi

exec otelcol --config="$config" "$@"
