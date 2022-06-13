# Use Trivy to monitor Docker vulnerabilities

* Status: accepted

## Context and Problem Statement

How might we ensure the security of our Docker images?

## Decision Drivers

* Shift left: Eliminate issues as early as possible
* CI/CD integration

## Considered Options

* Docker bench security
* dockle
* trivy

## Decision Outcome

Chosen option: [trivy](https://github.com/aquasecurity/trivy)

Docker bench security does not integrate with CI/CD.

Trivy, while open source, is supported by Aqua Security and a thriving support scene. Dockle is not and has a smaller, slower growing user base.
