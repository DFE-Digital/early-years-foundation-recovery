# Use Azure Managed Redis For Distributed Application Caching

* Status: accepted

## Context and Problem Statement

Production and staging run multiple web instances. Each instance has its own
process-local Rails cache, so a value written by one instance is invisible to
the others. The reason for Redis is not to share arbitrary page or user data;
the application has two concrete web-request uses that benefit from a shared
cache:

- Bot-authentication failures are counted by scope and client IP, with a limit
  of 20 attempts in five minutes. With process-local caches, distributing
  requests across instances gives each instance a separate counter and weakens
  the effective limit. A shared counter applies the limit across instances.
- GOV.UK One Login signing keys (JWKS) are fetched and cached. Sharing the entry
  avoids duplicate fetches by each instance and makes refreshes or invalidations
  visible to the other instances.

There are no direct `Rails.cache` calls in the background-job code today. Redis
does not replace user sessions, persistent data, or the PostgreSQL-backed
background job queue.

Azure Cache for Redis Basic, Standard, Premium, and Enterprise offerings are
being retired. Microsoft recommends Azure Managed Redis as their successor.
Azure Managed Redis is powered by Redis Enterprise; its current SKU names use
tiers such as `Balanced_B0`, not the retired `Enterprise_*` SKU names.

## Decision Drivers

- Enforce the bot-authentication failure counter consistently across web
  instances.
- Reuse and invalidate GOV.UK One Login signing keys across web instances.
- Keep Redis a disposable cache, not a source of truth.
- Restrict access to private networking and encrypted connections.
- Keep staging and production isolated while containing costs.
- Avoid introducing a Redis dependency into local development or replacing Que.
- Use Microsoft's current managed Redis offering rather than a retiring service.

## Considered Options

1. Keep the existing process-local cache.
2. Use the retiring Azure Cache for Redis service.
3. Use Azure Managed Redis for staging and production.

## Decision Outcome

Chosen option: 3.

Run Terraform separately for staging and production. The Redis resource count
is one when `environment` is either `staging` or `production`, and zero for
development; consequently this provisions one instance per staging or
production environment, not one instance shared between them. The web instances
within an environment share that environment's cache. Use the smallest Balanced
SKU, `Balanced_B0` (0.5 GB), as the initial size. Enable high availability in
production and disable it in staging, where cache data is disposable. Reassess
the SKU using memory use, evictions, latency, and connection metrics before
scaling.

Disable public network access. Connect through a private endpoint and private
DNS, use TLS on the Redis endpoint, and allow Redis traffic only from the web
app and worker subnets. Use the Enterprise clustering policy to provide a
single endpoint compatible with the existing Rails Redis client. Redis uses
access-key authentication for that client; the connection URL is passed to the
web app and worker as an application setting or secure container environment
variable. Background workers receive the Redis connection setting, but no job
currently calls `Rails.cache` directly. Terraform state and access to it must
therefore be protected.

Rails uses Redis for `Rails.cache` only when `REDIS_URL` is present. Redis
failures behave as cache misses. GOV.UK One Login can use a stale cached JWKS if
a refresh fails. If Redis is unavailable, bot authentication still rejects
invalid credentials, but its shared rate-limit counter cannot be maintained and
cross-instance throttling is not guaranteed until Redis recovers. Cache entries
have a one-hour default expiry, with call sites allowed to set a shorter expiry,
and Redis evicts least-recently-used keys when full. The live app and green slot
use separate namespaces. Local development and review apps remain unchanged.

Use AzureRM 4.67.0 and Terraform 1.12.2 for this infrastructure. Disable broad
automatic resource-provider registration, but explicitly configure Terraform
to register `Microsoft.Cache`. The identity running Terraform must have Azure
permission to register resource providers. This avoids requiring the team to
register this provider manually while avoiding automatic registration of the
provider's broader resource set.

Apply the infrastructure before deploying an application image that requires
Redis. Review a Terraform plan for each environment before applying, especially
the AzureRM 3.x to 4.x upgrade, which may expose unrelated provider changes.
Verify regional SKU availability and subscription pricing before provisioning.

## Consequences

- Web instances share bot-authentication counters and the JWKS cache only within
  their environment; the live app and green slot have separate namespaces.
- Redis outages leave credential validation active but temporarily weaken
  cross-instance rate limiting and may cause additional JWKS fetches. Cached
  values do not replace the database or become authoritative application data.
- Production high availability and private endpoints add cost; staging avoids
  high-availability charges because its cache is disposable.
- The Redis access key is stored in Terraform state and must be treated as a
  secret. Managed identity authentication can be considered separately if the
  Rails Redis client gains suitable token-refresh support.
- The AzureRM upgrade requires careful plan review before applying to existing
  staging and production state.