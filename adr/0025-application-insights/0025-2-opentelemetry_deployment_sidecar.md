# Embedded OpenTelemetry Collector

## Context and Problem Statement

We need to deploy the OpenTelemetry Collector alongside our Rails application to process and export traces to Azure Application Insights. The Collector acts as an intermediary, converting OTLP traces from the app into Azure Monitor-compatible data.

However, our hosting environment (Azure Web Apps for Containers) is optimized for running a single container per specific app service. Deploying a traditional "sidecar" (multi-container pod) is complex and requires significant infrastructure changes (Moving to Kubernetes or Azure Sidecars/Container Apps).

## Decision Drivers

- Need for reliable telemetry (tracing) in Production.
- Desire to minimize infrastructure complexity (Terraform changes).
- Constraint: Azure Web Apps typically runs one container image.

## Considered Options

- **External Collector:** Run a centralized Collector service. (Adds network complexity/latency/cost).
- **Kubernetes / Sidecars:** Move to AKS or Container Apps. (Migration overhead too high).
- **Embedded Sidecar (Chosen):** Bundle the Collector binary inside the Rails container image.

## Decision Outcome

We chose to **Embed the Collector** directly into the Docker image.

### Side-by-side Splunk rollout

To allow a gradual migration away from Azure Application Insights without breaking the existing telemetry path, the embedded collector exports telemetry to Splunk Observability Cloud and Azure Monitor in parallel.

The application emits spans over OTLP/HTTP only to the local collector. When the Splunk environment variables are set, the collector exports to:

- Azure Monitor via the Application Insights connection string
- Splunk Observability via its configured exporters

The Splunk export is enabled only when the following environment variables are set on the collector:

- `SPLUNK_REALM`
- `SPLUNK_ACCESS_TOKEN`

Routing all telemetry through the collector ensures its privacy processors run before either export.

### Implementation Details

1.  **Multi-Stage Build**: We fetch the `otelcol-contrib` binary from the official image during the Docker build.
2.  **Startup Wrapper**: A supervisor script starts both the collector and application, forwards termination signals, and stops the application if the collector fails.
    ```bash
    /usr/local/bin/start-with-otel rails server
    ```
3.  **Local Communication**: The Rails app sends traces to `localhost:4318`.

### Specific Handling for Background Workers

The Web App automatically uses the `CMD` defined in the Dockerfile.
However, **Background Workers** (running in Azure Container Instances) typically override the default command (e.g., specifying `que` directly).
To support tracing in workers, the deployment workflow must _explicitly_ wrap the worker command:

```yaml
command-line: "sh -c 'otelcol --config=/etc/otel-collector-config.yml >/dev/null 2>&1 & exec que'"
```

## Consequences

- **Positive**: Zero infrastructure changes required. Deployment is atomic (App + Config + Collector).
- **Positive**: Low latency (localhost communication).
- **Negative**: Container image size increases slightly (~60MB).
- **Negative**: Logs from the collector are discarded (`/dev/null`) to prevent noise, making collector debugging harder in production (must remove redirection to debug).
