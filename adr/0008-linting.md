# Use Gov.UK Rubocop for code linting

* Status: accepted

## Context and Problem Statement

How might we ensure the consistency of our code syntax?

## Decision Drivers <!-- optional -->

* Uniformity across DfE projects
* Linting of application code and test suite
* Ruby-based conventions

## Considered Options

* standard
* rubocop
* govuk-rubocop

## Decision Outcome

Chosen option: The [govuk](https://github.com/alphagov/rubocop-govuk) version of
[rubocop](https://rubocop.org/) is the preferred solution for government projects
and also conforms to a more Ruby-like syntax, unlike `standard`.
