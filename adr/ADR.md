# Architectural Decision Record Log

This log lists the architectural decisions for EYFS Recovery

<!-- adrlog -->

* [ADR-0000](0000-template.md) - Template
* [ADR-0001](0001-web-framework.md) - Primary development language and framework
* [ADR-0002](0002-development-environments.md) - Development Environments
* [ADR-0003](0003-video-hosting-platform.md) - Use YouTube as Video Hosting solution
* [ADR-0004](0004-authentication.md) - Use Devise for authentication
* [ADR-0005](0005-content-storage-strategy.md) - Use YAML + Markdown for Content
* [ADR-0006](0006-secrets-management.md) - Use Bitwarden for secrets management
* [ADR-0007](0007-deployment-environments.md) - Production, Integration, Staging and Content Preview environments will be resourced
* [ADR-0008](0008-infrastructure-as-code.md) - Use Terraform for infrastructure as code
* [ADR-0009](0009-linting.md) - Use Gov.UK Rubocop for code linting
* [ADR-0010](0010-security-vulnerabilities.md) - Use Trivy to monitor Docker vulnerabilities
* [ADR-0011](0011-postcodes.md) - Use UK_Postcode for validation and normalisation (rejected)
* [ADR-0012](0012-event-tracking.md) - Event Tracking
* [ADR-0013](0013-accessibility-standards.md) - Use Pa11y CI to ensure WCAG standards
* [ADR-0014](0014-sensitive-data-encryption.md) - Use Active Record Encryption to protect sensitive data
* [ADR-0015](0015-user-tracking.md) - Use Hotjar for tracking user journeys
* [ADR-0016](0016-background-jobs.md) - Use Que for processing background jobs
* [ADR-0017](0017-password-vulnerability.md) - Use Devise Security and Devise Pwned Passwords
* [ADR-0018](0018-external-authentication.md) - Use GOV.UK One Login
* [ADR-0019](0019-clarity-metrics) - Switch to Microsoft Clarity to track user journeys
* [ADR-0020](0020-telemetry-collector-app-insights-dev.md) - Introduce OpenTelemetry and Azure Application Insights using a Telemetry Collector Container
* [ADR-0021](0021-opentelemetry_deployment_sidecar.md) - Embedded OpenTelemetry Collector

<!-- adrlogstop -->

For new ADRs, please use [0000-template.md](0000-template.md) as basis.

Run `./bin/docker-adr` after adding or updating records to update this TOC using [adr-log](https://adr.github.io/adr-log/)

More information on MADR is available at <https://adr.github.io/madr/>.

General information about architectural decision records is available at <https://adr.github.io/>.
