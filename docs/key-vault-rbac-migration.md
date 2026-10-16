# Key Vault RBAC migration

## Current status

- The migration is being rebuilt safely on `keyvault-misconfig-final`. The
  original one-step Key Vault change is preserved in commit `431aee8c`.
- The migration will be validated in staging before production.
- The deployment identity currently has `Contributor` at subscription scope.
  This does not include `Microsoft.Authorization/roleAssignments/write`.
- Staging has been recovered and the vault has `enableRbacAuthorization` set to
  `false`.
- The undeclared-variable warnings are separate from the Key Vault failure. The
  workflow currently passes all GitHub environment variables and secrets to
  Terraform through auto-loaded variable files.

## Immediate recovery

- [x] Revert the Key Vault migration on `main` and deploy staging.
- [x] Confirm the legacy Key Vault access policies have been restored:
  - GitHub Actions can manage certificates and read secrets.
  - The Application Gateway managed identity can read the certificate secret.
- [x] Confirm the staging application and Application Gateway are healthy.
- [x] Confirm the current certificate is available and has not been replaced or
  deleted.

## Deployment identity

The Terraform workflows use the environment-specific `TF_AZURE_CLIENT_ID`
secret and GitHub OIDC federation for the onboarded deployment app registration.
Application deployment continues to use `AZURE_CLIENT_ID`.

The pinned AzureRM 3.71.0 provider determines `principal_type` automatically;
it does not support configuring this attribute. If Azure role-assignment
conditions require an explicit principal type, a separately validated provider
upgrade is needed. The direct cutover does not bypass authorization conditions.

Terraform manages the scoped assignments. Do not request an unrestricted
User Access Administrator grant as part of this migration.

## Direct RBAC cutover

Terraform enables Key Vault RBAC, creates the six scoped role assignments, and
removes all three legacy access policies in the same apply. This is a direct
cutover; access-policy rollback is not part of this deployment.

Before running the workflow:

- Confirm the selected environment uses its intended GitHub OIDC identity.
- Confirm the deployment identity can create the required role assignments at
  the Key Vault scope.
- Ensure Terraform can refresh the existing certificate issuer and certificate
  before the apply. The previous staging plan failed because the new identity
  lacked certificate `Get` and `GetIssuers` access while the vault still used
  access-policy authorization. The assignments in this plan do not grant that
  access until the vault switches to RBAC.
- Run `plan only` and review the complete plan. It should enable RBAC, create
  the six intended role assignments, remove the three access policies, and
  contain no unrelated destructive changes.
- Apply during the agreed change window, allow time for role propagation, and
  validate staging before repeating in production.

## Validation

After each apply:

- [ ] Confirm `enableRbacAuthorization` has the expected value:

  ```bash
  az keyvault show \
    --name <key-vault-name> \
    --subscription <subscription-id> \
    --query properties.enableRbacAuthorization
  ```

- [ ] Confirm the expected role assignments exist at the exact vault scope.
- [ ] Confirm Terraform can read and update the certificate issuer and
  certificate without a `403` response.
- [ ] Confirm Application Gateway can retrieve the certificate secret and its
  listener is healthy.
- [ ] Confirm the staging site serves HTTPS with the expected certificate.
- [ ] Run a second Terraform plan and confirm it is empty.
- [ ] Review Key Vault diagnostics and alerts for denied requests.

## Follow-up cleanup

- [ ] Change the Terraform variable-generation workflow to emit only declared
  Terraform inputs, or pass non-Terraform values through `TF_VAR_*` selectively.
  This will remove the undeclared-variable warnings and make plans easier to
  review.
- [ ] Update the Checkov suppression comments that still describe access
  policies after the migration is complete.
- [ ] Document who owns the permanent `User Access Administrator` grant and
  whether it should remain Key Vault-scoped for future Terraform changes.
