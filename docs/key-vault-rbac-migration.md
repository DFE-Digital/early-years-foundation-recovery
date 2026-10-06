# Key Vault RBAC migration

## Current status

- The proposed changes are preserved on `keyvault-misconfig-final` at commit
  `0595cdb7`. The original Key Vault change is commit `431aee8c`.
- Staging uses the `s187-eyrecovery-test` subscription and the
  `s187t01-eyrecovery-kv` Key Vault.
- The deployment identity currently has `Contributor` at subscription scope.
  This does not include `Microsoft.Authorization/roleAssignments/write`.
- The failed deployment left the staging vault with
  `enableRbacAuthorization` set to `false`.
- The undeclared-variable warnings are separate from the Key Vault failure. The
  workflow currently passes all GitHub environment variables and secrets to
  Terraform through auto-loaded variable files.

## Immediate recovery

- [ ] Revert the Key Vault migration on `main` and deploy staging.
- [ ] Confirm the two legacy Key Vault access policies have been restored:
  - GitHub Actions can manage certificates and read secrets.
  - The Application Gateway managed identity can read the certificate secret.
- [ ] Confirm the staging application and Application Gateway are healthy.
- [ ] Confirm the current certificate is available and has not been replaced or
  deleted.

## Required Azure permission

An Azure Owner or User Access Administrator must grant the GitHub Actions
service principal permission to manage role assignments. Use the narrowest
scope possible.

For staging, an authorised administrator must run:

```bash
az role assignment create \
  --assignee-object-id 72b0605a-56ae-4fdb-a29f-9744a510e53d \
  --assignee-principal-type ServicePrincipal \
  --role "User Access Administrator" \
  --scope "/subscriptions/192fdb22-10a0-4602-a72f-592069bf1ddc/resourceGroups/s187t01-eyrecovery-rg/providers/Microsoft.KeyVault/vaults/s187t01-eyrecovery-kv"
```

- [ ] Grant the staging deployment identity `User Access Administrator` on the
  staging Key Vault.
- [ ] Record the equivalent production deployment identity and Key Vault scope.
- [ ] Grant the production permission only after staging migration succeeds.
- [ ] Confirm the grants with `az role assignment list` before running
  Terraform.

## Prepare a safe migration

Do not switch the permission model and delete the existing access policies in
one apply. Prepare the migration as separate, reviewable phases.

### Phase 1: Add RBAC assignments

- [ ] Branch from the reverted `main`, then bring forward the monitoring changes
  and the required RBAC resources from `keyvault-misconfig-final`.
- [ ] Keep `enable_rbac_authorization` disabled.
- [ ] Keep both existing `azurerm_key_vault_access_policy` resources.
- [ ] Add the following Key Vault-scoped assignments:
  - GitHub Actions: `Key Vault Certificates Officer`.
  - GitHub Actions: `Key Vault Certificate User`.
  - GitHub Actions: `Key Vault Secrets User`.
  - Application Gateway managed identity: `Key Vault Secrets User`.
- [ ] Run and review the staging Terraform plan. It must add role assignments
  without deleting access policies or changing the vault permission model.
- [ ] Apply the plan and verify all four assignments in Azure.

Role assignments can exist while the vault still uses access policies. They
will take effect when Azure RBAC is enabled.

### Phase 2: Switch to Azure RBAC

- [ ] Add `enable_rbac_authorization = true` while retaining the legacy access
  policy resources for rollback context.
- [ ] Ensure certificate issuer and certificate resources depend on the GitHub
  Actions role assignments.
- [ ] Run a fresh staging plan and confirm the vault permission-model change is
  the only access-control transition.
- [ ] Apply during an agreed change window.
- [ ] Allow time for Azure RBAC propagation before testing data-plane access.
- [ ] Validate staging using the checks below.

### Phase 3: Remove legacy policies

- [ ] After staging has remained healthy, remove the two legacy access policy
  resources. They are ignored by the vault after Azure RBAC is enabled.
- [ ] Apply and validate staging again.
- [ ] Repeat the same three phases for production. Do not combine them into one
  production apply.

## Validation

After each apply:

- [ ] Confirm `enableRbacAuthorization` has the expected value:

  ```bash
  az keyvault show \
    --name s187t01-eyrecovery-kv \
    --subscription 192fdb22-10a0-4602-a72f-592069bf1ddc \
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

## Rollback

If Phase 2 causes an outage:

1. Set `enable_rbac_authorization` back to `false` without removing the legacy
   access policies.
2. Apply the rollback.
3. Confirm GitHub Actions and Application Gateway access through the restored
   access-policy model.
4. Retain the RBAC assignments while investigating; they are not active for
   Key Vault data-plane access when Azure RBAC is disabled.

## Follow-up cleanup

- [ ] Change the Terraform variable-generation workflow to emit only declared
  Terraform inputs, or pass non-Terraform values through `TF_VAR_*` selectively.
  This will remove the undeclared-variable warnings and make plans easier to
  review.
- [ ] Update the Checkov suppression comments that still describe access
  policies after the migration is complete.
- [ ] Document who owns the permanent `User Access Administrator` grant and
  whether it should remain Key Vault-scoped for future Terraform changes.
