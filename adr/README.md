# Architectural Decision Record Log

This log lists the architectural decisions for EYFS Recovery

<!-- adrlog -- Regenerate the content by using "adr-log -i". You can install it via "npm install -g adr-log" -->

* [ADR-0000](0000-template.md) - Template
* [ADR-0001](0001-web-framework.md) - Primary development language and framework
* [ADR-0002](0002-development-environments.md) - Development Environments
* [ADR-0003](0003-video-hosting-platform.md) - Use YouTube as Video Hosting solution
* [ADR-0004](0004-authentication-technology.md) - Use Devise for authentication
* [ADR-0005](0005-content-storage-strategy.md) - Use YAML + Markdown for Content
* [ADR-0006](0006-secrets-management.md) - Use Bitwarden for secrets management
* [ADR-0007](0007-deployment-environments.md) - Production, Integration, Staging and Content Preview environments will be resourced
* [ADR-0008](0008-linting.md) - Use Gov.UK Rubocop for code linting
* [ADR-0009](0009-security-vulnerabilities.md) - Use Trivy to monitor Docker vulnerabilities
* [ADR-0010](0010-postcodes.md) - Use UK_Postcode for validation and normalisation
* [ADR-0011](0011-event-tracking.md) - Event Tracking
* [ADR-0012](0012-accessibility-standards.md) - Use Pa11y CI to ensure WCAG standards
* [ADR-0013](0013-sensitive-data-encryption.md) - Use Active Record Encryption to protect sensitive data

<!-- adrlogstop -->

For new ADRs, please use [0000-template.md](0000-template.md) as basis.

If using the ```adr-log``` tool ([here](https://adr.github.io/adr-log/)) then run ```adr-log -i README.md``` to update this TOC after adding a record or run `./bin/docker-adr`.

More information on MADR is available at <https://adr.github.io/madr/>.
General information about architectural decision records is available at <https://adr.github.io/>.

<!-- markdownlint-disable-file MD013 -->
