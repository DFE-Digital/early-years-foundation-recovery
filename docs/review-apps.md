# Review apps

Review apps let you try a PR without waiting for staging. Each app has its own
database and uses a GOV.UK One Login simulator instead of real One Login accounts.

## Open a review app

1. Add the **review** label to an open PR.
2. Wait for the review deployment workflow to finish. Any approvals required by the
   development environment still apply.
3. Open the URL in the PR's **Review app verified** comment. The comment includes
   the commit that was tested.

New commits update the same app, including documentation-only changes. Review apps
are only available for PRs from this repository, not forks.

## Sign in

Select **Continue to GOV.UK One Login** to open the test account picker.

- Enter a made-up name such as `alex-test`, then select **Sign in with this test account**.
- Use the same name to return to that account on the same review app.
- Select **Create new test user** to generate a unique name. Note it down if you
  want to use that account again.

Names can contain lowercase letters, numbers and hyphens, up to 40 characters.
There are no preset accounts or passwords. The first time you use a name, complete
registration as you would for a new user. Use **Sign out** when you have finished.

**Use test data only.** Anyone who can access the review app can sign in with the
same test account name. These are not real One Login accounts, and review URLs may
be publicly accessible. Do not enter personal information or copy live data into
a review database.

## What to expect

- Account data stays in place when a new commit is deployed. You will need to sign
  in again after deployment.
- Removing the **review** label or closing the PR deletes the app and its database.
  Adding the label again creates a fresh app.
- Email delivery, reporting uploads, scheduled jobs and browser analytics are disabled.
- Contentful content is shared, not copied for each PR.
- A restart can interrupt sign-in. Start again from the application's sign-in page.

## Update or recreate an app

To update an app without losing its data, push a commit while the **review** label
is present. If a deployment fails, check the error, fix the cause and use
**Re-run all jobs** on the latest review deployment.

For a fresh app:

1. Remove the **review** label.
2. Wait for cleanup to succeed in Actions.
3. Add the label again and wait for the new verified URL.

**This permanently deletes the review database and all its accounts.** Do not
remove the label just to update the code.

If cleanup fails, check the Azure error and rerun the cleanup job. It is safe to
retry when some resources have already been removed.

## Troubleshooting

Start with the failed step in the review deployment workflow. Failed verification
uploads a diagnostics artifact containing screenshots, page HTML, browser errors
and Azure startup logs where available. Artifacts are kept for seven days and may
contain test-session details; do not paste them into public comments.

| Problem | What to check |
| --- | --- |
| App returns 503 or never becomes healthy | Check Azure container startup logs for image-pull errors, Rails boot errors or failed migrations. A failed deployment may leave the slot stopped. |
| Login callback returns 502 | Check the ingress logs. `upstream sent too big header` means the proxy response-header buffer is too small. |
| Sign-in fails after a deployment or restart | Start again from the application's sign-in page. If it still fails, check the slot's hostname, callback URLs and signing configuration. |
| Previous account seems to be missing | Use the exact same test account name on the same review app. Accounts are deleted when the app is cleaned up. |
| Emails or reporting updates do not arrive | These are deliberately disabled. |
| Cleanup fails | Check both the slot and database: one may already have been deleted. Fix the reported error before retrying. |

If Azure's streaming logs fail, download the logs with `az webapp log download`.
Rails output can appear in the startup failure log as `ContainerStream` entries.
Never share private keys, connection strings or full app-setting dumps in PR comments.

## Developer checks

The deployment workflow checks health, the sign-in link and the browser login
journey before posting a verified URL. The browser test covers a new account,
saved account details, returning-user login and explicit logout. It does not test
the whole training journey.

To run those checks against an existing review app:

```sh
export REVIEW_APP_URL='https://<slot hostname>'
export GOV_ONE_CLIENT_ID=review-pr-123
bash .github/scripts/smoke_sign_in.sh "$REVIEW_APP_URL" review
node --test spec/e2e/gov_one_login.test.mjs
```

Use the client ID for the PR you are testing. Browser tests create test accounts
in that app's database.

For local login coverage:

```sh
bash bin/login-e2e
# On macOS, if Puma worker forking fails:
WEB_CONCURRENCY=0 bash bin/login-e2e
```

The local runner uses HTTP and a report-only content security policy. Deployed
review apps use HTTPS and enforce the production policy.

To check the deployment scripts, ingress and account picker:

```sh
SMOKE_SKIP_COVERAGE_CHECK=true bundle exec rspec \
  spec/deployment/review_app/deployer_spec.rb \
  spec/lib/review_app_configuration_spec.rb
bash .github/scripts/test_review_ingress.sh
node --test spec/e2e/review_account_picker.test.mjs
```

## Hosting and maintenance

Each PR uses a `pr-N` slot on the review App Service, with three containers:
Nginx, Rails and the pinned One Login simulator. Nginx serves the account picker
and routes authentication requests to the simulator. The simulator's configuration
API is blocked.

Each slot has its own database, signing credentials and callback URLs. Simulator
login is restricted to review slots; other environments keep their normal login.
Database credentials are shared at server level, so review apps must only run
trusted internal code.

Keep the review plan on **one worker with autoscaling disabled**. The simulator
holds authentication state in memory, so multiple workers can break sign-in.
Slots share the plan's CPU and memory: check capacity and slot availability before
increasing concurrent use.

The deployment identity needs permission to manage slots, sidecars, slot settings,
network integration and PR databases. Container images must be anonymously pullable
from GHCR. Networking must allow PostgreSQL access and requests to the review app's
own HTTPS hostname.

The workflow serialises deployment and cleanup for each PR. Do not make manual
Azure changes while a workflow for that PR is running. Cleanup for closed PRs uses
the script on the default branch, which must contain the cleanup implementation.

If workflow cleanup cannot be used, run the helper from a trusted checkout after
selecting the **development subscription** with `az account set`:

```sh
export PR_NUMBER=pr-123
export AZURE_RESOURCE_GROUP='<development resource group>'
export REVIEWAPP_NAME='<review parent app>'
export POSTGRES_SERVER='<development PostgreSQL server>'
ruby .github/scripts/review_app.rb cleanup
```

This removes the PR slot, its sidecars and database. It does not remove shared
infrastructure, container images, Contentful content or database backups.

### Outstanding platform work

Development and production PostgreSQL servers were observed running version 13
in November 2026. Its community support ended on 13 November 2025. The coordinated
upgrade is tracked in [#1982](https://github.com/DFE-Digital/early-years-foundation-recovery/issues/1982);
confirm Azure support arrangements with the platform owner.

Before wider use, agree a concurrent-app capacity limit and verify two apps running
together, commit updates, and label-removal/PR-close cleanup. Record those results,
the team demo and technical/product review in the PR or ticket.
