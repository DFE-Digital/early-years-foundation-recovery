# Splunk Observability

The application sends traces, correlated application logs, service metrics, container/process metrics, and collector health metrics through the OpenTelemetry Collector. When Splunk credentials are present, the collector exports to both Splunk Observability Cloud and Azure Monitor. Without Splunk credentials, production uses Azure Monitor only; local development uses the debug exporter.

## Configuration

Required secrets:

- `SPLUNK_ACCESS_TOKEN`
- `SPLUNK_REALM`
- `APPLICATION_INSIGHTS_CONNECTION_STRING` while dual export is enabled

Resource identity is supplied through `OTEL_SERVICE_NAME`, `OTEL_SERVICE_VERSION`, and `OTEL_RESOURCE_ATTRIBUTES`. Never put credentials, user data, request parameters, or job arguments in resource attributes.

Each application process writes a sanitized, bounded rotating JSON log to `/tmp/telemetry/application-<container>-<pid>.json.log`. The container identifier prevents app and worker processes with the same namespace-local PID from sharing a file. When a replacement process starts, it removes rotations belonging to dead PIDs from its own container. The collector tails these files and promotes valid `trace_id` and `span_id` fields into OpenTelemetry log context. Existing stdout logs remain available to Azure container diagnostics.

## Local Verification

Start the normal development stack without Splunk credentials to use the collector debug exporter:

```sh
docker compose -f docker-compose.yml -f docker-compose.dev.yml up
```

With `SPLUNK_REALM` and `SPLUNK_ACCESS_TOKEN` set locally, the same command selects the dual-export configuration. Do not commit these values.

Validate collector configuration without sending telemetry:

```sh
docker run --rm \
  -e APPLICATION_INSIGHTS_CONNECTION_STRING=InstrumentationKey=00000000-0000-0000-0000-000000000000 \
  -e SPLUNK_REALM=eu0 \
  -e SPLUNK_ACCESS_TOKEN=test \
  -e OTEL_SERVICE_NAME=early-years-foundation-recovery \
  -e OTEL_SERVICE_VERSION=test \
  -e OTEL_RESOURCE_ATTRIBUTES=deployment.environment.name=test \
  -v "$PWD/otel-collector-config.yml:/etc/otelcol/config.yaml:ro" \
  otel/opentelemetry-collector-contrib:0.161.0 \
  validate --config=/etc/otelcol/config.yaml
```

## Deployment Verification

Deploy to development first, then verify all of the following for both the web and worker containers:

1. A normal request produces a trace with `service.name`, `service.version`, `service.instance.id`, `deployment.environment.name`, `cloud.provider`, and `cloud.platform`.
2. A controlled request failure marks its span as an error and includes an exception event.
3. A Que job produces a `CONSUMER` span named `que.process <job class>`.
4. Application logs appear with matching trace and span IDs where an active span exists.
5. `service.calls`, `service.duration`, and related span-derived metrics appear after the 60-second flush interval.
6. `system.cpu`, `system.memory`, `system.filesystem`, `system.network`, and Ruby/collector process metrics appear.
7. Collector self-metrics beginning with `otelcol_` appear.
8. Azure Monitor continues receiving traces, logs, and metrics.

Inspect representative log and trace records to ensure tokens, email addresses, IP addresses, user IDs, query strings, cookies, authorization headers, and database statements are absent.

## Alerts and Dashboards

Create Splunk detectors scoped by `service.name` and `deployment.environment.name` for:

- request error rate and latency from span-derived metrics
- collector refused and dropped spans, logs, and metrics
- exporter send failures and retry queue saturation
- collector restarts and missing collector self-metrics
- sustained collector memory-limiter activation
- worker consumer-span failures

Start with development data and tune thresholds before enabling production notifications. Keep metric dimensions bounded; do not group by raw URL, query string, request ID, exception message, user ID, or job ID.

## Failure Test

In a disposable environment, replace the Splunk token with an invalid value. Confirm collector export errors remain visible on container stdout and the Rails health endpoint continues responding. Restore the token and confirm export resumes. Do not perform this test in production.

## Rollback

1. Remove `SPLUNK_ACCESS_TOKEN` or `SPLUNK_REALM` to select the Azure-only collector configuration.
2. Redeploy the previous application image if application logging or process supervision is implicated.
3. Confirm Rails health and Azure Monitor ingestion.
4. Retain collector stdout from the failed deployment for diagnosis; never publish expanded environment variables or collector configuration containing secrets.
