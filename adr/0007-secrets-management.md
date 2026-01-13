# Use Bitwarden for secrets management

* Status: proposed

## Context and Problem Statement

How might we best manage secrets, keys etc. within the application environment?

## Decision Drivers

* Security
* Cost
* Ease of use
* Portability

## Considered Options

* HashiCorp Cloud Vault
* Bitwarden
* GitHub Secrets
* Azure KeyVault

## Decision Outcome

Proposed option: Bitwarden requires a fixed $5 pcm per user fee for access to the system. A single account would be required. Access to Bitwarden is via authenticated REST API. 

Bitwarden is open source and has achievedSOC2 Type 2 and SOC 3 certification proving the system is both secure and effective and has been independently audited and approved by multiple external CyberSecurity companies.

Use of HashiCorp Vault cloud was not recommended as, despite being the secure creds sector leader, usage costs are difficult to estimate due to the opacity of the billing mechanism.

Use of GitHub secrets may tie us to the GitHub platform, which may be undesirable in the long term.

Use of Azure KeyVault in DfE's Azure cloud instance would require us to bridge network environments from Gov.uk PaaS to Azure which would need to undergo security review which may not be deliverable within out timeline. Also, it would require additional DevOps resource to setup.