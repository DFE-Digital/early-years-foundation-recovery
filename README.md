# Early Years Recovery

[![Continuous Integration][ci-badge]][ci-workflow]

## Getting Started

1. Clone the repository. This is a Rails 7 application using [the DfE template][rails-template]
2. Obtain the master keys. Optionally create `.env` to override default variables.
3. Run! (*running locally in the production rails environment requires self-signed certificates*)

## Useful Links

- [Project Documentation][confluence]
- [Production Environment][production]
- [Staging Environment][staging]
- [Prototype Repo][prototype-repo]
- [Prototype App][prototype-app]
- [Flow Diagram][figma]

## Rails Credentials

We use rails credentials to manage secrets. If you need to modify secrets for one
of the deployed environments, you can get the encryption keys from another developer on the team.

Once you have the keys, run `rails credentials:edit --environment <env>`.
Full instructions can be found by running `rails credentials:help`

---

## Working locally

**Development**

> Gemfile group :development

Use `bin/dev` to start the process workers (watching for changes to asset files).

**Testing**

> Gemfile group :test

Use `bin/rspec` to run the test suite under `/spec`.
Rails system specs use RackTest only for efficiency.

**UI Framework**

> Gemfile group :ui

Use `bin/qa` to run the test framework under `/ui` against a given URL.
These tests have additional dependencies:

- `brew install chromedriver geckodriver`
- `xattr -d com.apple.quarantine /usr/local/bin/chromedriver`

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

- `bin/docker-dev` starts `Procfile.dev`, containerised equivalent of `bin/dev`,
    using the `docker-compose.dev.yml` override
- `bin/docker-rails db:seed` populates the containerised postgres database
- `bin/docker-rails console` drops into a running development environment or starts one,
    containerised equivalent of `bin/rails console`
- `bin/docker-rspec -f doc` runs the test suite with optional arguments, containerised
    equivalent of `bin/rspec`
- `bin/docker-qa` runs the browser tests against a running production application, a containerised equivalent of `bin/qa`

These commands can be used to debug problems:

- `docker ps` lists all active **Docker** processes
- `docker system prune` tidies up your system
- `docker-compose -f docker-compose.yml -f docker-compose.<FILE>.yml --project-name recovery run --rm app`  can help identify why the application is not running in either the `dev`, `test`, or `qa` contexts
- `BASE_URL=https://app:3000 docker-compose -f docker-compose.yml -f docker-compose.qa.yml --project-name recovery up app` debug the UAT tests


---

## Deployment Pipeline

- [Production][production] is deployed automatically when a version is tagged.
- [Staging][staging] is deployed automatically with the latest commit from `main`.
- Manually adding the **"deployed"** label to a pull request in Github will cause it to be deployed.
  This supports manual testing and content review in a production environment.
- Changes to the **"/ui"** folder will automatically label the PR with **"deployed"** and trigger deployment.
  This supports automated UA tests.
- When a feature branch review application is deployed, the URL to access it is added as a comment in the PR conversation in the format: <https://ey-recovery-pr-##.london.cloudapps.digital/>
- Review applications are deployed with 3 seeded user accounts that share a restricted password.
  This facilitates team members demoing content and functionality, so registration is not required.

## Quality Assurance

The UI/UA test suite can be run against any site. A production-like application is available as a composed Docker service for local development. To run a self-signed certificate must first be generated.

1. `./bin/docker-certs` (Mac users can trust the certificate in [Keychain Access](https://support.apple.com/en-gb/guide/keychain-access))
2. `./bin/docker-qa` (this will build and bring up the application)
3. `docker exec -it recovery_prod rails db:seed` (seed the pre-requisite user accounts)
4. `BASE_URL=https://app:3000 ./bin/docker-qa` (test against the seeded application)

WIP: proposed Github workflow that does not require `docker-compose`.

---

## Emails

Emails are sent using the [GOV.UK Notify][notify].

### Getting a GovUK Notify account

You need an account before you can use [GOV.UK Notify][notify] to send emails.
To obtain one ask a current member of the team to add you to the PQ tracker service,
by navigating to the `Team members` page and clicking the `Invite a team member`
button and entering a government email address.
This will send an email inviting you to use the service.

### Getting a key for local development

The credentials file for the development environment holds an API key for Notify;
it is a test only and does not send out emails. We use test keys in local development
to ensure we do not send out too many emails. If it is necessary to send emails
from your local machine, you can use a `Team and whitelist` API key.

- Sign into [GOV.UK Notify][notify]
- Go to the ‘API integration’ page
- Click ‘API keys’
- Click the ‘Create an API’ button
- Choose the ‘Team and whitelist’ option.
- Copy your key and add it to your `.env` with the name `GOVUK_NOTIFY_API_KEY`


## Accessing information in the Notify service

Once you have an account you can view the `Dashboard` with details of how many emails have been sent out and any that have failed to send. 

You can update the content of the emails in the `Templates` section.

## For more information

Documentation for GovUK Notify can be found here: <https://docs.notifications.service.gov.uk/ruby.html>

The status of GovUK notify can be checked here: <https://status.notifications.service.gov.uk/>

For more information the Notify team can be contacted here: <https://www.notifications.service.gov.uk/support>,
or in the UK Government digital slack workspace in the `#govuk-notify` channel.

---

## Content

### YAML

- [guide](https://www.commonwl.org/user_guide/yaml)

### Govspeak

- [live preview](https://govspeak-preview.publishing.service.gov.uk)
- [designer guide](https://govspeak-preview.publishing.service.gov.uk/guide)
- [developer guide](https://docs.publishing.service.gov.uk/repos/govspeak.html)


---

[confluence]: https://dfedigital.atlassian.net/wiki/spaces/ER/overview
[production]: https://eyfs-covid-recovery.london.cloudapps.digital
[staging]: https://ey-recovery-staging.london.cloudapps.digital
[prototype-repo]: https://github.com/ife-dev1/DFE-Digital-early-years-foundation-recovery
[prototype-app]: https://eye-recovery.london.cloudapps.digital
[rails-template]: https://github.com/DFE-Digital/rails-template
[ci-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml
[notify]: https://www.notifications.service.gov.uk
[figma]: https://www.figma.com/file/FGW1NJJwnYRqoZ2DV0l5wW/Training-content?node-id=1%3A19

