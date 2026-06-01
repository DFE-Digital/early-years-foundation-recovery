# EYCDTK-1402: Start Training Reminder Timing Update

## Summary

The "Start the training" reminder has been updated to send earlier for users who have
completed registration but have not started any module.

- Previous timing: 4 weeks after email confirmation
- New timing: 1 week after email confirmation

## Why

Sending this reminder earlier increases the chance that users start training while
registration intent is still fresh.

## Eligibility Rules

The reminder is sent only when all conditions are met:

- user is registered
- user has not started any module
- user can receive training emails
- user confirmed their account 1 week ago (day window)

## Duplicate Protection

To avoid unnecessary duplicate sends, eligible users are excluded when they already have:

- a delivered start training mail event
- a queued start training mail delivery job

## Technical Notes

- Updated recipient scope for `StartTrainingMailJob`
- Added a 1-week confirmation scope for this reminder flow
- Added/updated specs for:
  - recipient timing change
  - duplicate exclusion behavior
  - queued start training mail job filtering

## Validation

Run locally:

```sh
bin/docker-rspec spec/jobs/start_training_mail_job_spec.rb spec/models/user_spec.rb spec/models/job_spec.rb spec/models/data_analysis/user_overview_spec.rb
```
