# Use Que for processing background jobs

* Status: accepted

## Context and Problem Statement

How might we handle processing background jobs?

## Decision Drivers

* Potential use and cost of [Redis](https://redis.io/)
* Potential use and cost of dedicated worker nodes

## Considered Options

* [Arask](https://github.com/Ebbe/arask)
* [Sidekiq](https://github.com/sidekiq/sidekiq)

## Decision Outcome

Chosen option: [Que](https://github.com/que-rb/que) ruby library
