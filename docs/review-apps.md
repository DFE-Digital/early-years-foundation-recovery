# Azure review apps

## Access and identities

Add **review** to an internal PR. Fork PRs cannot deploy with environment credentials.
The workflow builds the PR head commit, deploys it, runs smoke/browser verification,
then posts a URL and the verified commit SHA on the PR. New commits update that slot.
Documentation-only commits also deploy. The development GitHub environment's approval
and branch protection rules still apply.

On **Continue to GOV.UK One Login**, the simulator displays a response configuration
form. Use synthetic data only:

| Purpose | Subject (`sub`) | Email |
| --- | --- | --- |
| First reviewer | `review-alex-1` | `review-alex-1@example.com` |
| Another reviewer | `review-sam-1` | `review-sam-1@example.com` |

Use a new subject **and** email for a new account. Reuse both for a returning account.
The subject is the stable One Login identifier. Keep Email Verified selected; leave
the other defaults unchanged. Complete registration in the application as usual.
Use **Sign out** to exercise simulator logout and clear the Rails session.

These are not real One Login accounts. Review URLs are publicly reachable unless
additional Azure access restrictions are configured; anyone with access can impersonate
a synthetic identity. Never enter real personal data or copy a live database into a
review app. The simulator is not an authentication boundary for sensitive information.

## Architecture and isolation

Each `pr-N` slot has:

- Nginx as the only externally routed container, listening on 8080.
- Rails on 3000 with `RAILS_ENV=production`, `ENVIRONMENT=review`.
- GOV.UK One Login simulator `26.10.8` on 4001 in interactive mode.
- A `pr-N` PostgreSQL database and dedicated, generated review signing key.
- A `review-pr-N` client ID, exact HTTPS login and logout callbacks on the slot's
  actual Azure `defaultHostName`, and a separate session signing secret.

App Service sidecars share the slot's localhost network and app settings. The simulator's
container-specific environment overrides map `PORT` and other simulator variables to
review-only app settings. Rails explicitly maps `WEBSITE_SLOT_NAME` to the slot's
`REVIEW_SLOT_NAME` setting: sidecar processes do not reliably inherit the platform's
slot-name variable. The existing review-only boot guard remains enabled.
Rails serves its compiled static assets, and the ingress allows larger response
headers for the CSP and session cookies returned by login redirects.
No extra DNS names, certificates or simulator App Services
are required. The ingress image is built from the same commit as Rails.

Only `/authorize`, `/form-submit`, `/logout`, `/token`, `/userinfo`,
`/.well-known/openid-configuration` and `/.well-known/jwks.json` go to the simulator.
Nginx returns 404 for `/config` and descendants; all other paths go to Rails.
Nginx forwards HTTPS metadata to Rails behind Azure's TLS termination.

Simulator mode fails at boot outside an explicitly opted-in `ENVIRONMENT=review`
PR slot. Staging, production and deployed development retain their existing One Login
configuration. Review apps cannot deliver Action Mailer emails, do not schedule Que
jobs, and reject dashboard uploads even if explicitly requested or `DASHBOARD_UPDATE` is inherited.
The slot also clears Notify and reporting bucket settings. No worker container is
provisioned, and browser analytics are suppressed even with cookie consent.
Contentful uses the review parent's configured environment; content is
shared, not copied per PR. Database isolation does not imply database-role isolation:
slots still use the existing server credential, so only trusted internal code may run.

## Deployment and cleanup

One workflow reconciles opened/reopened/labeled/unlabeled/synchronized/closed PRs.
It rechecks the live PR state to ignore stale head commits and reconcile the latest
label/closed state. A PR-specific concurrency group covers build, deploy, verification
and teardown; running operations are not cancelled mid-provisioning. Changes during a
build are reconciled by the queued run.

Existing databases/slots are reused. New slots are created without cloning the parent
image/settings, avoiding even a temporary boot against the parent's database.
Required parent app settings and network access/TLS restrictions are copied onto the
stopped slot with the PR-specific overrides. The slot is stopped while
its settings and containers are updated, then started with the requested SHA image.
Only slot configuration is changed; the shared parent's `DATABASE_URL` is never changed.
Signing keys and session secrets rotate on each deployment, so reviewers must sign in
again. Database/account data persists until cleanup. Migrations run at Rails startup.
The ingress image and Rails image must be anonymously pullable from GHCR, as the
existing application image is; GitHub Actions' build login is not Azure runtime auth.

Closing the PR or removing **review** deletes the slot (including sidecars) and
`pr-N` database. On an open PR, cleanup uses the script from that PR's head commit.
On a closed PR, cleanup uses the default branch so it remains available after the PR
branch is deleted. This means open-PR cleanup does not require merging the changes first.
Absent resources are explicitly logged and skipped. Permission/network/Azure errors
are failures, not treated as missing resources. Database cleanup is still attempted if
slot cleanup fails; the run fails with the operations requiring attention.

For partial deployments, fix the reported error and rerun the workflow. A deploy
failure deliberately leaves the slot stopped rather than serving a partially
configured app. Remove the label to clean up instead. Repeated cleanup is safe.
Use Actions **Re-run all jobs** on the closed/unlabeled run if cleanup failed.
Do not run manual mutations concurrently with an Actions run.

### Recreate an app for an existing PR

1. Make sure the PR is open, comes from this repository, and the review workflow and
   cleanup script have been merged to the default branch. Confirm the PR's current
   head commit is the one you want to review.
2. In the PR's **Checks** tab, make sure no review-app run is in progress.
3. If the **review** label is already present and you need a clean recreation, remove
   it. Wait for the review workflow's cleanup run to succeed before continuing. Removing
   the label permanently deletes the slot **and its `pr-N` database and review data**.
   Do not remove/re-add it if you need to keep that data.
4. Add the **review** label. This starts a deployment for the PR's current head commit.
   If the label is already absent, just add it; if it is already present and the
   app needs an update rather than deletion, use **Re-run all jobs** on the latest
   failed review deployment instead.
5. Wait for the deployment, smoke check, and browser login/logout verification to
   succeed. Use the review URL in the PR's updated **Review app verified** comment.
   The workflow rechecks the PR label and head SHA, so a stale run will not publish
   an outdated commit. If a new commit is pushed during a run, wait for the newer
   synchronize run to finish.

If teardown fails, inspect the failed step and Azure error before retrying cleanup.
If deployment fails partway through, fix the cause first; the app is intentionally
left stopped. Rerun the failed deployment, or remove the label, wait for successful
cleanup, and add it again for a fresh database. Never run manual Azure changes while
an Actions run for the same PR is active.

If manual recovery is necessary, authenticate to the development subscription and
run the same script from a trusted checkout, after ensuring no workflow is running:

```sh
export PR_NUMBER=pr-123
export AZURE_RESOURCE_GROUP='<development resource group>'
export REVIEWAPP_NAME='<review parent app>'
export POSTGRES_SERVER='<development PostgreSQL server>'
ruby .github/scripts/review_app.rb cleanup
```

Cleanup does not remove shared infrastructure, images, shared content or Azure
database backups. Retention for those resources is managed separately.

## Azure readiness

Read-only inspection on 11 November 2026 confirmed:

| Check | Result |
| --- | --- |
| Hosting | Linux custom containers on a dedicated review P1v2 plan, one worker |
| HTTPS and networking | Parent requires HTTPS and has VNet integration with route-all enabled |
| Current configuration | Classic Docker configuration; only PR slots are converted to `sitecontainers` |
| Slots | One existing review slot; P1v2 supports up to 20 slots, subject to current Azure quotas |
| Recent plan load | Observed CPU average about 8%, maximum 29%; memory average about 65%, maximum 67% |
| PostgreSQL | Development and production Flexible Servers both report major version 13 |

These observations are not a capacity guarantee. All slots share plan CPU and memory,
including the parent application. Obtain an agreed simultaneous-review budget and
measure startup and peak usage with the three-container pilot before general use.
Do not scale the review plan above one worker or enable autoscaling: simulator
authorization codes/tokens are held in memory. The deployment refuses a multi-worker
plan; `alwaysOn` and one worker per slot are configured. Restarts and deployments
discard simulator state; restart the sign-in journey after either. ARR affinity alone
is not sufficient for Rails backchannel requests across multiple simulator instances.

Before rollout, the platform owner must confirm:

- Current regional/App Service support for sidecars on **slots**, remaining slot quota,
  available memory/CPU under concurrent starts, and any access restrictions.
- The GitHub OIDC principal has slot create/read/write/delete, app configuration,
  sitecontainer create/update/delete, VNet/subnet join, plan read, and PostgreSQL
  database list/create/delete permissions. The interactive CLI user's access does
  not verify the deployment identity's permissions.
- Runner Azure CLI supports `webapp sitecontainers create --sitecontainers-spec-file`
  and slot targeting (validated locally with CLI 2.91.0).
- VNet DNS/outbound routing permits PostgreSQL, GHCR and the slot's own HTTPS hostname
  for OIDC token/userinfo/discovery requests. Only ingress receives external traffic.
- Azure can pull both GHCR images and the simulator, and the inherited Rails master
  key/content configuration is appropriate for trusted synthetic-data review apps.

PostgreSQL 13 reached community end of life on 13 November 2025. Coordinated upgrade
work is tracked in [#1982](https://github.com/DFE-Digital/early-years-foundation-recovery/issues/1982).
Confirm Azure support/extended-support status and staging's version with the platform
owner. Do not change the Terraform database major version as an incidental review-app
deployment: rehearsal, backups, compatibility checks and a release window are required.

## Verification and troubleshooting

Local interactive login coverage:

```sh
bash bin/login-e2e
# On macOS, if Puma worker forking fails:
WEB_CONCURRENCY=0 bash bin/login-e2e
```

The local runner uses the test environment's report-only CSP default explicitly:
enforcing `upgrade-insecure-requests` on this HTTP-only local harness upgrades browser
form requests to HTTPS, which the local Puma listener does not serve. Deployed review
apps use HTTPS and retain the enforced production CSP.

Verification against an already deployed review app (synthetic accounts only):

```sh
export REVIEW_APP_URL='https://<slot hostname>'
export GOV_ONE_CLIENT_ID=review-pr-123
bash .github/scripts/smoke_sign_in.sh "$REVIEW_APP_URL" review
node --test spec/e2e/gov_one_login.test.mjs
```

The browser creates a unique synthetic identity per run, checks the real callback,
protected pages, saved name, returning-user login in a fresh browser context, and
explicit logout denying further authenticated access. It does not complete the entire
training journey. The review smoke check validates the exact simulator hostname,
callback and core OIDC parameters, and rejects an exposed configuration API.
Other environments retain their account.gov.uk smoke checks.

Workflow failures upload HTML, screenshots and browser errors under `tmp/login-e2e`,
plus container image/role information and an Azure startup-log archive when available.
Filesystem container logging is enabled before starting the slot. If streaming logs
return an error, use `az webapp log download` and inspect the startup failure log,
including its `ContainerStream` entries. Diagnostics may contain
synthetic authentication session data: restrict artifact access and use the seven-day
retention. For startup failures inspect Azure Deployment Center/container logs and
Rails migration logs; never post configuration dumps, private keys or connection
strings in PR comments.

Common causes:

- **502 / health timeout:** image pull, port mismatch, failed migrations, capacity, or
  a stopped slot following a failed deployment. Check all three containers.
- **Invalid callback/token:** hostname, client ID or public key mismatch; retry after
  a deployment/restart and verify exact slot settings without publishing secrets.
- **Callback cannot reach simulator:** check VNet DNS/outbound HTTPS and ingress routing.
- **Account not recognised:** reuse the same subject and email, not just a name.
- **No email/report export:** intentionally disabled in review.
- **Cleanup failure:** check Azure stderr and permissions, then rerun; inspect both
  slot and database, as either may already have been deleted.

Local regression commands:

```sh
bundle exec rspec spec/deployment/review_app/deployer_spec.rb
bash .github/scripts/test_review_ingress.sh
SMOKE_SKIP_COVERAGE_CHECK=true bundle exec rspec spec/lib/review_app_configuration_spec.rb
```

## Rollout evidence still required

- Deploy an eligible internal PR and record the working URL and requested SHA.
- Run two PR apps concurrently; verify different accounts/databases/configuration.
- Push a commit and verify it replaces the existing app without losing account data.
- Remove the label and close a PR; verify slot, sidecars and database disappear.
- Exercise failed/partial deployment and repeated cleanup with the deployment identity.
- Record peak resource use, permissions/network checks and the agreed capacity budget.
- Demonstrate access, identity selection, returning login and logout to the development
  team; add playback notes and obtain technical/product review before sign-off.

No live deployment, team playback or peer/product approval is implied by local tests.

References: [App Service sidecars](https://learn.microsoft.com/en-us/azure/app-service/configure-sidecar),
[sitecontainer CLI](https://learn.microsoft.com/en-us/cli/azure/webapp/sitecontainers),
[simulator interactive mode](https://github.com/govuk-one-login/simulator/blob/26.10.8/docs/interactive-mode.md),
[PostgreSQL support policy](https://www.postgresql.org/support/versioning/).
