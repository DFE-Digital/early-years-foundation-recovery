# Early years child development training

[![ci][ci-badge]][ci-workflow]
[![brakeman][brakeman-badge]][brakeman-workflow]
[![pa11y][pa11y-badge]][pa11y-workflow]
[![qa][qa-badge]][qa-workflow]

This is a Rails 7 application using the [DfE template][rails-template].

Optionally create `.env` to override or set default variables like `DATABASE_URL`.

## Getting Started

1. Clone the [repository][app-repo]
2. Install [git-secrets](#git-secrets)
3. Obtain the master keys
4. Start the server

## Useful Links

- [Project Documentation][confluence]
- [Production Environment][production]
- [Staging Environment][staging]
- [Prototype Repo][prototype-repo]
- [Prototype App][prototype-app]
- [Experts & Mentors Interim App][interim-prototype-app]
- [Flow Diagram][figma]

## Rails Credentials

We use rails credentials to manage secrets; obtain the encryption keys from the dev team.

To edit, use either:

```sh
$ EDITOR=vi rails credentials:edit --environment <env>
$ ./bin/docker-rails credentials:edit --environment <env>
```

Full instructions can be found by running `rails credentials:help`

## Git Secrets

This will help to prevent unintentional commits of access keys.

```sh
$ brew install git-secrets
$ cd ./path/to/repo
$ git secrets --install
$ git secrets --register-aws
```

Find advanced settings and other installation options at the [git-secrets project][git-secrets].

---

## Working locally

```sh
$ asdf plugin add ruby
$ asdf install ruby
$ asdf plugin add postgres
$ asdf install postgres
$ asdf plugin add nodejs
$ asdf install nodejs
```

**Development**

> Gemfile group :development

Use `bin/dev` to start the process workers (watching for changes to asset files).

**Testing**

> Gemfile group :test

Use `bin/rspec` to run the test suite under `/spec`.
Rails system specs use RackTest only for efficiency.

**Production**

Running locally in the production rails environment requires generating a self-signed certificate. Use `bin/docker-certs`

**UI Framework**

> Gemfile group :ui

Use `bin/qa` to run the test framework under `/ui` against a given URL.
These tests have additional dependencies:

```sh
$ brew install chromedriver geckodriver
# on OSX Intel
$ xattr -d com.apple.quarantine /usr/local/bin/chromedriver
# on OSX ARM
$ xattr -d com.apple.quarantine /opt/homebrew/bin/chromedriver
```

## Using Docker

Containerised services are available for use by developers and testers.
There are a number of convenience scripts to make working with **Docker** easier.
All containers for the project are named with the prefix `recovery_`.
The project uses chained **Docker Compose** files to prepare different environments.

These commands help maintain your containerised workspace:

- `bin/docker-build` creates tagged images for all the services
- `bin/docker-certs` generates a self-signed certificate for running the app in production
- `bin/docker-files` changes the ownership of files to your current user, files
    generated inside containers are created by *root*
- `bin/docker-down` stop any active services
- `bin/docker-prune` purge project containers, volumes and images

The commands run common tasks inside containers:

- `bin/docker-adr` rebuilds the architecture decision records table of contents
- `bin/docker-dev` starts `Procfile.dev`, containerised equivalent of `bin/dev`,
    using the `docker-compose.dev.yml` override
    Additionally, it will install bundle and yarn dependencies.
- `bin/docker-rails erd` generate an Entity Relationship Diagram
- `bin/docker-rails db:seed` populates the containerised postgres database
- `bin/docker-rails console` drops into a running development environment or starts one,
    containerised equivalent of `bin/rails console`
- `bin/docker-rspec -f doc` runs the test suite with optional arguments, containerised
    equivalent of `bin/rspec`
- `bin/docker-doc` runs a YARD documentation server
- `bin/docker-uml` exports UML diagrams as default PNGs
- `bin/docker-prod` starts rails in production under `https`
- `bin/docker-qa` runs the browser tests against a running production application,
    a containerised equivalent of `bin/qa`
- `bin/docker-pa11y` runs WCAG checks against a generated `sitemap.xml`

These commands can be used to debug problems:

- `docker ps` lists all active **Docker** processes
- `docker system prune` tidies up your system
- `docker-compose -f docker-compose.yml -f docker-compose.<FILE>.yml --project-name recovery run --rm app`
    can help identify why the application is not running in either the `dev`, `test`, or `qa` contexts
- `BASE_URL=https://app:3000 docker-compose -f docker-compose.yml -f docker-compose.qa.yml --project-name recovery up app` debug the UAT tests

## Using Rake

Custom tasks are namespaced under `eyfs`, list them using `rake --tasks eyfs`.

```sh
# Generate secure bot user
$ rake eyfs:bot
# Que job to insert page view events for injected module items
$ rake eyfs:jobs:plug_content
# Recalculate module completion time
$ rake eyfs:user_progress
# Enable the post login 'What's new' page
$ rake eyfs:whats_new
```

---

## Deployment Pipelines

Visit the [Github Container Registry][ghcr].

[Development][development] is deployed automatically with the latest commit from `main`.

Adding the `review` label to a pull request in Github will trigger a deployment for review.
Once a feature branch is deployed, the URL to access it is added as a comment
in the PR conversation in the format: <https://eyrecovery-review-pr-##.azurewebsites.net>

We intend to use [semantic versioning](https://semver.org/).

[Staging][staging] is deployed from this [workflow][staging-workflow].
[Production][production] is deployed from this [workflow][production-workflow].


## Azure

Production console access

- https://eyrecovery-dev.scm.azurewebsites.net/webssh/host
- https://eyrecovery-stage.scm.azurewebsites.net/webssh/host
- https://eyrecovery-prod.scm.azurewebsites.net/webssh/host

## Monitoring

[Sentry][sentry] is used to monitor production environments

`$ brew install getsentry/tools/sentry-cli`

`$ sentry-cli projects list --org early-years-foundation-reform`

    +---------+--------------+-------------------------------+--------------+
    | ID      | Slug         | Team                          | Name         |
    +---------+--------------+-------------------------------+--------------+
    | 6274627 | eyf-reform   | early-years-foundation-reform | Rails        |
    | 6274651 | eyf-recovery | early-years-foundation-reform | eyf-recovery |
    +---------+--------------+-------------------------------+--------------+

## Quality Assurance

The UI/UA test suite can be run against any site.
A production-like application is available as a composed Docker service for local development.
To run a self-signed certificate must first be generated.

1. `./bin/docker-certs` (Mac users can trust the certificate in [Keychain Access](https://support.apple.com/en-gb/guide/keychain-access))
2. `./bin/docker-qa` (this will build and bring up the application with a clean database)
3. `./bin/docker-prod-reset` (clean and reseed the prerequisite user accounts)
4. `./bin/docker-qa` (retest)
4. `BASE_URL=https://deployment ./bin/docker-qa` (alternative test against another server)


## Accessibility Standards

An automated accessibility audit can be run against a development server running
in Docker using `./bin/docker-pa11y`. The test uses [pa11y-ci](https://github.com/pa11y/pa11y-ci)
and a dynamic `sitemap.xml` file to ensure the project meets [WCAG2AA](https://www.w3.org/WAI/WCAG2AA-Conformance) standards.
A secure HTTP header `BOT` is used to provide access to pages that require authentication.
The secret `$BOT_TOKEN` environment variable defines the account to seed.

```
curl -i -L -H "BOT: ${BOT_TOKEN}" http://localhost:3000/my-account
```

`docker-pa11y` accepts an optional argument to test external sites.

---

## Emails

Emails are sent using the [GOV.UK Notify][notify].

### Getting a GovUK Notify account

You need an account before you can use [GOV.UK Notify][notify] to send emails.
To obtain one ask a current member of the team to add you to the "Early Years Foundation Recovery" service,
by navigating to the `Team members` page and clicking the `Invite a team member`
button and entering a government email address.
This will send an email inviting you to use the service.

The credentials file for each environment holds an API key for [Notify][notify]:

- `railsdevelopment-...` Team and guest list (limits who you can send to)
- `railstest-...` Test (pretends to send messages)
- `railsproduction-...` Live (sends to anyone)

It is possible to temporarily override the key by defining `GOVUK_NOTIFY_API_KEY` in `.env`.

### Accessing information in the Notify service

Once you have an account you can view the `Dashboard` with details of how many
emails have been sent out and any that have failed to send.

You can update the content of the emails in the `Templates` section.

### For more information

Documentation for GovUK Notify can be found here: <https://docs.notifications.service.gov.uk/ruby.html>

The status of GovUK notify can be checked here: <https://status.notifications.service.gov.uk/>

For more information the Notify team can be contacted here: <https://www.notifications.service.gov.uk/support>,
or in the UK Government digital slack workspace in the `#govuk-notify` channel.

---

# GOV.UK One Login

### Account Registration

Register an account on the integration OIDC used in development <https://signin.integration.account.gov.uk/sign-in-or-create>.
Using this authentication method also requires basic HTTP auth credentials.

### Status Updates

For status updates see <https://status.account.gov.uk/>

### Questions

Questions can be directed to the `#govuk-one-login` slack channel <https://ukgovernmentdigital.slack.com/archives/C02AQUJ6WTC>

### Credentials

- Integration GOV.UK One Login environment credentials are stored in Rails development credentials (`config/credentials/development.yml.enc`)
- Both production and integration GOV.UK One Login environment credentials are stored in Rails production credentials (`config/credentials/production.yml.enc`).

---

## Service Dashboard

Key performance metrics are surfaced in a [Looker Studio](https://lookerstudio.google.com/navigation/reporting) dashboard and refreshed daily.
User [service accounts](https://cloud.google.com/iam/docs/service-accounts) can authenticate using the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install).


**Storage and Reporting**

- [Cloud Storage](https://console.cloud.google.com/storage/browser?project=eyfsdashboard)
- [Development Dashboard](https://lookerstudio.google.com/reporting/4d48f463-022b-4fb8-9262-26c22f6b2e8d)
- [Development Bucket](https://console.cloud.google.com/storage/browser/eyfs-data-dashboard-development)
- [Staging Dashboard](https://lookerstudio.google.com/reporting/8f550461-c4e7-4c9f-b597-6f27669ff14c)
- [Staging Bucket](https://console.cloud.google.com/storage/browser/eyfs-data-dashboard-staging)
- [Production Dashboard](https://lookerstudio.google.com/reporting/095cfc94-d1d2-4a32-a2ba-d5899c3ecea5)
- [Production Bucket](https://console.cloud.google.com/storage/browser/eyfs-data-dashboard-live)

**Downloading exported data**

- `gcloud auth login`
- `gcloud config set project eyfsdashboard`
- `gsutil ls` (list buckets)
- `gsutil -m cp -r "gs://eyfs-data-dashboard-live/eventsdata" "gs://eyfs-data-dashboard-live/useranswers" .` (export folders recursively)


---

## User experience

Session timeout functionality:

- default timeout period is 25 minutes
- default timeout warning appears after 5 minutes
- screen readers announce every time the timeout refreshes every 15 secs

---

## Hotjar

This project uses Hotjar for user insight. Hotjar records user journeys and
automatically redacts certain user information on recordings. All personally
identifiable information should be redacted. In order to override the default
settings the following classes can be added:
- `data-hj-suppress` to redact additional user information
- `data-hj-allow` to allow data that is automatically redacted


---

[app-repo]: https://github.com/DFE-Digital/early-years-foundation-recovery
[prototype-repo]: https://github.com/DFE-Digital/ey-recovery-prototype
[rails-template]: https://github.com/DFE-Digital/rails-template
[ghcr]: https://github.com/dfe-digital/early-years-foundation-recovery/pkgs/container/early-years-foundation-recovery
[confluence]: https://dfedigital.atlassian.net/wiki/spaces/ER/overview
[notify]: https://www.notifications.service.gov.uk
[figma]: https://www.figma.com/file/FGW1NJJwnYRqoZ2DV0l5wW/Training-content?node-id=1%3A19
[docker]: https://www.docker.com
[git-secrets]: https://github.com/awslabs/git-secrets
[sentry]: https://sentry.io/organizations/early-years-foundation-reform

<!-- Deployments -->

[prototype-app]: https://eye-recovery.herokuapp.com
[interim-prototype-app]: https://child-development-training-prototype.london.cloudapps.digital
[production]: https://child-development-training.education.gov.uk
[staging]: https://staging.child-development-training.education.gov.uk
[development]: https://eyrecovery-dev.azurewebsites.net
[review]: https://eyrecovery-review-pr-123.azurewebsites.net

<!-- GH workflows -->

[brakeman-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/brakeman.yml
[pa11y-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/pa11y.yml
[ci-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml
[production-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/production.yml
[staging-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/staging.yml
[qa-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/qa.yml

<!-- GH workflow badges -->

[brakeman-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/brakeman.yml/badge.svg
[pa11y-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/pa11y.yml/badge.svg
[ci-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml/badge.svg
[qa-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/qa.yml/badge.svg
