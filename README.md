# Early Years Recovery

[![Continuous Integration][ci-badge]][ci-workflow]


## Development using Docker

Containerised services in development have exposed ports for local access.

- `bin/docker-build` creates tagged docker images
- `bin/docker-dev` starts `Procfile.dev`, containerised equivalent of `bin/dev`
- `bin/docker-rails console` drops into a running dev environment or starts one
- `bin/docker-rspec -f doc` runs the test suite with optional arguments

Permissions on any files generated within Docker, in the development environment with a mounted volume, will be owned by root.
You can correct the permissions in your local working directory by running `bin/docker-files`.

## Rails Credentials

We use rails credentials to manage secrets. If you need to modify secrets for one
of the deployed environments, you can get the encryption keys from another developer on the team.

Once you have the keys, run `rails credentials:edit --environment <env>`.
Full instructions can be found by running `rails credentials:help`

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
[ci-badge]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml/badge.svg
[ci-workflow]: https://github.com/DFE-Digital/early-years-foundation-recovery/actions/workflows/ci.yml
[notify]: https://www.notifications.service.gov.uk
