# Child development training

[![Continuous Integration][ci-badge]][ci-workflow]

## Getting Started

1. Clone the repository

  This is a Rails 7 application using the [DfE template][rails-template].

2. Obtain the master keys

  Optionally create `.env` to override or set default variables like `DATABASE_URL`.

3. Install the frontend dependencies

  - `yarn install; bin/rails assets:precompile`
  - `bin/docker-yarn` if using [Docker][docker]

4. Start the server

  - `bin/dev` *(requires a running database server)*
  - `bin/docker-dev` if using [Docker][docker]

## Useful Links

- [Project Documentation][confluence]
- [Production Environment][production]
- [Staging Environment][staging]
- [Prototype Repo][prototype-repo]
- [Prototype App][prototype-app]
- [Experts & Mentors Interim App][interim-prototype-app]
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

**Production**

Running locally in the production rails environment requires generating a self-signed certificate. Use `bin/docker-certs`

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
- `bin/docker-dev-restart` restarts the running server
- `bin/docker-yarn` warm the cache of frontend dependencies

The commands run common tasks inside containers:

- `bin/docker-dev` starts `Procfile.dev`, containerised equivalent of `bin/dev`,
    using the `docker-compose.dev.yml` override.
    Additionally, it will install bundle and yarn dependencies.
- `bin/docker-rails db:seed` populates the containerised postgres database
- `bin/docker-rails console` drops into a running development environment or starts one,
    containerised equivalent of `bin/rails console`
- `bin/docker-rspec -f doc` runs the test suite with optional arguments, containerised
    equivalent of `bin/rspec`
- `bin/docker-qa` runs the browser tests against a running production application,
    a containerised equivalent of `bin/qa`

These commands can be used to debug problems:

- `docker ps` lists all active **Docker** processes
- `docker system prune` tidies up your system
- `docker-compose -f docker-compose.yml -f docker-compose.<FILE>.yml --project-name recovery run --rm app`
    can help identify why the application is not running in either the `dev`, `test`, or `qa` contexts
- `BASE_URL=https://app:3000 docker-compose -f docker-compose.yml -f docker-compose.qa.yml --project-name recovery up app` debug the UAT tests


---

## Deployment Pipeline

### Production Space

[Production][production] is deployed automatically when a version is tagged.
We use [semantic versioning](https://semver.org/) and a release can be triggered by:

- `git checkout main`
- `git tag v0.0.x`
- `git push origin v0.0.x`

### Staging Space

[Staging][staging] is deployed automatically with the latest commit from `main`.

### Content Space

Manually adding the **"deployed"** label to a pull request in Github will cause it to be deployed.
  This supports manual testing and content review in a production environment.
When a feature branch review application is deployed, the URL to access it is added as a comment in the PR conversation in the format: <https://ey-recovery-pr-##.london.cloudapps.digital/>
Review applications are deployed with 3 seeded user accounts that share a restricted password.
  This facilitates team members demoing content and functionality, so registration is not required.

## Quality Assurance

The UI/UA test suite can be run against any site. A production-like application is available as a composed Docker service for local development.
To run a self-signed certificate must first be generated.

1. `./bin/docker-certs` (Mac users can trust the certificate in [Keychain Access](https://support.apple.com/en-gb/guide/keychain-access))
2. `./bin/docker-qa` (this will build and bring up the application)
3. `docker exec -it recovery_prod rails db:seed` (seed the prerequisite user accounts)
4. `BASE_URL=https://app:3000 ./bin/docker-qa` (test against the seeded application)

WIP: proposed Github workflow that does not require `docker-compose`.

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

## Content

Content designers are using the docker development environment.
You can demo this environment locally using `completed@example.com:password`.
When the are significant changes to content structure or styling it may be necessary to either:

- `bin/docker-dev-restart` restart the server
- `bin/docker-rails assets:precompile` rebuild the assets

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
[prototype-repo]: https://github.com/DFE-Digital/ey-recovery-prototype
[prototype-app]: https://eye-recovery.herokuapp.com
[interim-prototype-app]: https://child-development-training-prototype.london.cloudapps.digital
[rails-template]: https://github.com/DFE-Digital/rails-template
[ci-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml
[notify]: https://www.notifications.service.gov.uk
[figma]: https://www.figma.com/file/FGW1NJJwnYRqoZ2DV0l5wW/Training-content?node-id=1%3A19
[docker]: https://www.docker.com
