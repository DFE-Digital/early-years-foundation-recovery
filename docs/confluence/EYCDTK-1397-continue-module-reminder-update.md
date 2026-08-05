# EYCDTK-1397: Continue Module Reminder Timing Update

## Summary

The "Continue the module" reminder has been updated to send earlier for users who have
started but have not completed a module.

- Previous timing: 4 weeks of inactivity
- New timing: 1 week of inactivity

## Why

Sending this reminder earlier increases the chance that users complete the module.

## Eligibility Rules

The reminder is sent only when all conditions are met:

- user is registered
- user can receive training emails
- user has started but not completed a module
- user has been inactive with the module for 1 week

## Technical Notes

- Added a 1-week confirmation scope for this reminder flow
- Added/updated specs for continue training mail job

## Validation

Run locally:

```sh
bin/docker-rspec spec/jobs/continue_training_mail_job_spec.rb
```
