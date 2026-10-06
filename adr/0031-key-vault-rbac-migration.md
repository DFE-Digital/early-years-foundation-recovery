# Migrate Azure Key Vault Authorization to RBAC in Phases

* Status: accepted

## Context and Problem Statement

Azure Key Vault currently uses access policies for data-plane authorization.
Azure role-based access control provides consistent, auditable role assignments
and supports monitoring of authorization changes.

The first migration attempted to enable RBAC, replace the existing policies, and
create role assignments in one Terraform apply. The deployment identity had
`Contributor`, which does not include
`Microsoft.Authorization/roleAssignments/write`. Azure rejected the permission
model change after the access policies had been removed, causing staging
certificate access to fail. Terraform could not restore the policies during a
normal plan because its refresh of the inaccessible certificate resources
failed first.

The migration must not create another interval where GitHub Actions,
Application Gateway, or the App Service certificate principal cannot access the
vault.

## Decision Drivers

- Avoid disruption to HTTPS certificate access.
- Preserve a tested rollback path throughout the migration.
- Use least-scope Azure control-plane permissions.
- Verify each authorization change in staging before production.
- Keep Key Vault access and authorization changes auditable.

## Considered Options

1. Switch the permission model and replace access policies in one apply.
2. Pre-stage RBAC assignments, switch the permission model, then remove legacy
   policies in separate applies.
3. Continue using Key Vault access policies permanently.

## Decision Outcome

Chosen option: 2.

The migration will use three separately planned and applied phases:

1. Retain all access policies and keep RBAC authorization disabled while adding
   the equivalent Key Vault-scoped RBAC assignments.
2. After verifying all assignments, enable RBAC authorization while retaining
   the access policy resources for immediate rollback.
3. After staging remains healthy, remove the legacy access policy resources.

The same phases will be completed and validated in staging before production.
They must not be combined into one production apply.

The GitHub Actions deployment identity requires `User Access Administrator` at
the Key Vault scope before Phase 1 can be applied. The deployment must stop if a
Phase 1 plan changes the vault permission model or removes an access policy.

## Consequences

- The migration requires multiple Terraform plans, reviews, and applies.
- Access policies and RBAC assignments temporarily coexist, but only the active
  Key Vault permission model controls data-plane access.
- Disabling RBAC authorization restores the retained access policies if Phase 2
  causes an access failure.
- GitHub Actions receives permission to manage role assignments at the Key
  Vault scope rather than at resource-group or subscription scope.
- Key Vault diagnostics and alerts monitor failed access, vault changes, and
  role-assignment changes.