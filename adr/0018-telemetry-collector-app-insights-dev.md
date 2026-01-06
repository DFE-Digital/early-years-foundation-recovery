## ADR: Introduce OpenTelemetry and Azure Application Insights using a Telemetry Collector Container

- **Status:** Accepted
- **Date:** 2025-12-08

## Context

We need reliable, modern observability for the Early Years Foundation Recovery service. Specifically, the team requires:

- Distributed tracing across the Rails application and worker processes
- Visibility into performance issues, bottlenecks, errors, and dependency latency
- A way to collect logs and metrics later without re-instrumenting the application
- Integration with Azure Application Insights, the DfE-standard monitoring platform
- A vendor-neutral approach built on open standards

The Azure Application Insights Ruby SDK is now effectively deprecated. It does not support OpenTelemetry, does not export traces in a modern format, and is missing several features required for distributed tracing. Therefore, we need a different approach.

## Decision

We will use **OpenTelemetry (Ruby)** inside the Rails application and deploy a sidecar **OpenTelemetry Collector** responsible for receiving traces and exporting them to Azure Application Insights using the Azure Monitor exporter.

### Summary of Architecture

```
flowchart LR
    A[Rails App<br/>OpenTelemetry Ruby] -->|OTLP/HTTP :4318| B[OpenTelemetry Collector]
    B -->|Azure Monitor Exporter| C[Azure Application Insights]
```

**Flow:**

1. Rails (web + workers) emits telemetry in OTLP/HTTP format
2. The OpenTelemetry Collector receives telemetry on port 4318
3. The collector transforms and exports that data to Azure Application Insights, using the standard Application Insights connection string
4. Azure receives the data as native Application Insights traces

### Why This Decision

#### 1. Best Available Option for Ruby

OpenTelemetry is now the standard for instrumentation across languages. The Ruby SDK is actively maintained and supports:

- Rails
- ActiveRecord
- Net::HTTP
- Sidekiq
- Custom spans
- Context propagation

This gives us high-quality tracing.

#### 2. Azure Does Not Accept OTLP Directly

Azure Application Insights does not expose an OTLP endpoint. It requires either:

- The (deprecated) AI Ruby SDK, or
- The Azure Monitor exporter via an OpenTelemetry Collector

The Collector therefore becomes essential.

#### 3. The Collector Isolates the Application from Vendor Details

If we switch from Azure in future (e.g., to Datadog, Honeycomb, or Jaeger), only the collector configuration changes — not the Rails code.

#### 4. The Collector Provides Reliability and Control

The collector brings:

- Batching
- Retries
- Backoff
- Memory buffering
- Filtering and redaction
- Multiple exporters (if needed)

This allows the app to remain lightweight.

#### 5. Logs & Metrics Can Be Added Later with Zero Code Changes

Because the Collector is already running, we can extend pipelines for:

- Logs → Application Insights
- Metrics → Application Insights
- Live metrics (with caveats; experimental)

The app does not change — only the collector config does.

### Alternatives Considered

#### 1. Azure Application Insights Ruby SDK

**Rejected.**

It is deprecated, missing key features, and does not support distributed tracing via OpenTelemetry.

#### 2. Sending OTLP Directly from Rails to Azure

**Rejected.**

Azure does not accept raw OTLP.

#### 3. Using a Commercial APM (Datadog/New Relic)

**Rejected.**

Would require procurement, licensing, and integration outside the scope and timeline.

#### 4. Not Implementing Tracing

**Rejected.**

This removes the team's ability to diagnose live issues effectively.

## Consequences

### Positive

- Modern distributed tracing works today across the whole application
- Fully compatible with Azure Application Insights
- Minimal changes to the Rails codebase
- Future-proof: logs and metrics can be added
- Deployment is container-friendly and consistent across environments
- No reliance on deprecated or vendor-specific Ruby SDKs

### Negative

- Introduces an additional container to operate (the Collector)
- Some additional operational knowledge required for maintaining collector pipelines
- Live Metrics support is limited and requires further validation

## Future Work

- Add log pipeline to collector
- Add metrics pipeline (if needed)
- Explore feasibility of Live Metrics (AI's "Live Metrics Stream")
- Add dashboards and alerts in Azure

## Usage

Developers can add custom telemetry using the `ApplicationInsightsTelemetry` helper module:

```ruby
# Add custom attributes to current span
ApplicationInsightsTelemetry.add_attributes(
  'user.role' => 'admin',
  'feature.enabled' => 'new_dashboard'
)

# Create a custom span
ApplicationInsightsTelemetry.with_span('processing_data', attributes: { 'record_count' => 100 }) do
  # your code here
end

# Record an exception
ApplicationInsightsTelemetry.record_exception(error)
```
