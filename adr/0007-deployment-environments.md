# Production, Integration/Staging and Content Preview environments will be resourced

* Status: proposed

## Context and Problem Statement

How might we specify the "Route-to-live" environments.

## Decision Drivers <!-- optional -->

* Costs need to be kept to a reasonable minimum
* Necessary and sufficient
* Simple to build, maintain and hand over
* Deployed using Terraform, GitHub Actions and Cloud Foundry
* An environment needs to be provided that enables the content editors to preview content as soon as possible and be updated at the request of the Content Editors.

## Considered Options

* All environments specified at the same level
* Pre-production environments use smaller resources

## Decision Outcome

Chosen option: Pre-production environments will use smaller environments.

Given that Heroku review apps are being used for feature testing, we have no need for a test environment.

*Content Preview* environment will be unencrypted as this environment is intended only to be used by internal users with no PII data contained. Deployment to Content Preview will be as frequently as the content editors required. Content Editor environment should be set to deploy a defined version, i.e. running behind the mainline, so the Content Editors are not impacted by unexpected issues.

*Integration/Staging* environment will be integrated with external dependencies and used for final User Acceptance Testing.

| Environment    | Database Size         | Compute Size              |
|:---------------|:----------------------|:--------------------------|
|Content Preview | small-unencrypted-9.5 | 1 app instance with 1 GiB |
|Integration     | small-ha-9.5          | 1 app instance with 1 GiB |
|Production      | medium-ha-13          | 1 app instance with 4GiB  |
