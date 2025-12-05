# Deployment Strategy: Embedded OpenTelemetry Collector

## The Challenge

We need to deploy the OpenTelemetry Collector alongside our Rails application to process and export traces to Azure Application Insights. However, Azure Web Apps (Linux) typically manages one container per app service, making a traditional "sidecar" container deployment complex to configure via Terraform key-value pairs alone.

## The Solution: Embedded Sidecar

We embed the Collector binary directly into the Rails application image and start it as a background process.

### How it works

1.  **Multi-Stage Build**: We use Docker's multi-stage build feature to fetch the official `otelcol-contrib` binary from the `otel/opentelemetry-collector-contrib` image.
2.  **Copy Binary**: This binary is copied to `/usr/bin/otelcol` in our production image. It is a static Go binary with no external dependencies.
3.  **Process Management**: We modify the `CMD` to start the collector in the background before launching Rails.

### The Command Explained

```dockerfile
CMD ["sh", "-c", "otelcol --config=/etc/otel-collector-config.yml >/dev/null 2>&1 & exec bundle exec rails server"]
```

- **`otelcol ... &`**: Starts the collector in the background (`&`). It begins listening on `localhost:4318` immediately.
- **`>/dev/null 2>&1`**: Redirects collector logs to null. This prevents the collector's internal logs from mixing with valid Rails application logs. (Errors are fail-safe; if the collector dies, the app continues).
- **`exec ...`**:Crucial for production. It replaces the current shell process with the Rails server process. This makes Rails `PID 1` (or the main process), ensuring it correctly receives `SIGTERM` signals for graceful shutdowns during deployment.

### Benefits

- **Zero Infrastructure Change**: No need to modify Terraform, Networking, or App Service configuration.
- **Atomic Deployment**: The app and its telemetry version deploy together.
- **Performance**: Communication happens over `localhost`, minimizing latency.
