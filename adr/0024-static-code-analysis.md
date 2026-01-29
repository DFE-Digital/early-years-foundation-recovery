# Static application security testing

* Status: accepted

## Context and Problem Statement
We need a reliable, automated and scalable static code analysis and application security testing solution for our Ruby on Rails application.

## Decision Drivers
* Suitable for use in GitHub Actions
* Integration with CI pipelines
* Surfaces actionable insights
* Minimises manual toil
* Aligns with automated testing, automated deployments, and IaC-driven workflows

## Considered Options
* CodeQL
* SonarCloud
* Do nothing (continue with manual scanning)

## Decision Outcome
Adopt CodeQL for SAST
