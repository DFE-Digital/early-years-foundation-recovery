# Bot authentication improvements

* Status: accepted

## Context and Problem Statement

There are several improvements which can be made to improve bot authentication processes and also the monitoring around this.

## Decision Drivers

- Improve bot authentication process
- Ensure there is better monitoring of endpoints

## Considered Options

1. Separate bot authentication logic per service
2. Add basic rate limiting on the endpoints

## Decision Outcome

- Update logic to split out bot authentication per service

## Consequences

- There is a bot token which is used per service
- Any issues in this area can be detected and resolved quickly
