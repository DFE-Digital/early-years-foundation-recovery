# Reduce Continue Module Reminder Delay To One Week

* Status: accepted

## Context and Problem Statement

Users who start but do not complete a training module currently receive the
"Continue the module" reminder when there is 4 weeks of inactivity. This is late for users who
are still deciding whether to continue engaging with the module and may result in the module not being completed at all.

The reminder should be sent sooner while preserving existing recipient eligibility rules:

- user has completed registration
- user has started but not completed a module
- user has opted in to training emails

## Decision Drivers

- Improve engagement in service
- Reduce the likelihood of not completing the module

## Considered Options

1. Keep 4-week timing.
2. Reduce to 1 week

## Decision Outcome

Chosen option: 2.

The continue module recipient window is reduced from 4 weeks to 1 week of inactivity.
The recipient query now excludes users who already have:

This keeps the reminder early

## Consequences

- Users are nudged earlier, increasing chance of module completion.
- Reminder eligibility remains limited to users who have a module in progress.
- No schedule frequency change is required; only recipient selection logic changed.
