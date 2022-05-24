# Use UK_Postcode for validation and normalisation

* Status: proposed

## Context and Problem Statement

How might we ensure the mandatory postcode field entered by a user is valid.

## Decision Drivers <!-- optional -->

- Third-party libraries provide additional functionality with zero tech-debt.
- Handling the validation in app adds a slight overhead with additional testing.

## Considered Options

- Using a regular expression to validate user input.
- [uk_postcode](https://rubygems.org/gems/uk_postcode)

## Decision Outcome

Chosen option: `uk_postcode` gem