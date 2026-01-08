# Deployment pipeline, and Infrastructure as Code

* Status: accepted

## Context and Problem Statement
How will we deploy infrastructure to the Azure environments?

## Decision Drivers

* Standard practice in DfE
* Industry standards
* Security
* Automated deployments with minimal manual intervention

## Considered Options

* Hashicorp Terraform
* Bicep

## Decision Outcome

Terraform, used by many DfE projects.

The team commits to deploying infrastructure through terraform and automated pipelines, with minimum click-ops in the Azure Portal.