# Reduce Start Training Reminder Delay To One Week

* Status: accepted

## Context and Problem Statement

Users who complete registration but do not start a training module currently receive the
"Start the training" reminder 4 weeks after email confirmation. This is late for users who
are still deciding whether to engage, and can reduce conversion from registration to
active learning.

The reminder should be sent sooner while preserving existing recipient eligibility rules:

- user has completed registration
- user has not started any module
- user has opted in to training emails

The reminder should also avoid duplicate deliveries caused by retries or job restarts.

## Decision Drivers

- Improve early engagement after registration
- Keep reminder audience narrowly targeted to non-starters
- Reduce risk of duplicate reminder emails
- Keep implementation low-risk and testable in existing job flow

## Considered Options

1. Keep 4-week timing.
2. Reduce to 1 week and keep existing duplicate behavior.
3. Reduce to 1 week and add explicit duplicate recipient exclusions.

## Decision Outcome

Chosen option: 3.

The start training recipient window is reduced from 4 weeks to 1 week after confirmation.
The recipient query now excludes users who already have:

- a delivered start training `MailEvent`
- a queued start training `ActionMailer::MailDeliveryJob`

This keeps the reminder early and prevents unnecessary repeat sends when jobs are retried
or overlap with queued delivery work.

## Consequences

- Users are nudged earlier, increasing chance of first module start.
- Reminder eligibility remains limited to users who have not started training.
- Duplicate reminders are less likely during operational retries/restarts.
- No schedule frequency change is required; only recipient selection logic changed.
