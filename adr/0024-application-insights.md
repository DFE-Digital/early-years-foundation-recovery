# Deploy Azure Application Insights

* Status: accepted

## Context and Problem Statement
How can we get metrics, and more diagnostic logging, for the service?

We need to be able to diagnose seemingly intermittent faults like learning log issues.

We would like to have an Azure dashboard with charts showing at a glance how the service's resources are performing.

## Decision Drivers
* Diagnostic logging
* Ability for the service to log traces from specific points in code
* Dashboard (with options to show traffic metrics and statuses of inbound requests)
* The service is a Rails app, so no easy integration option available

## Considered Options
* Azure Application Insights
* Open telemetry
* Do not implement

## Decision Outcome
Application Insights *via* an open telemetry collector configured to pass through to Application Insights

OTel collector can run in the same container as the service

More implentation details, and more around the reasoning behind this decision, are available at:
* [ADR-0024](./0024-application-insights/0024-1-telemetry-collector-app-insights-dev.md) - Introduce OpenTelemetry and Azure Application Insights using a Telemetry Collector Container
* [ADR-0024](./0024-application-insights/0024-2-opentelemetry_deployment_sidecar.md) - Embedded OpenTelemetry Collector
