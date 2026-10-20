# Use Azure Managed Redis For Distributed Application Caching

* Status: accepted

## Context and Problem Statement

Production and staging run multiple web workers and background workers. A
process-local Rails cache is not shared across workers, so cache entries cannot
be reused reliably across instances. We need a shared cache without changing
local development, user sessions, or the PostgreSQL-backed background job queue.

Azure Cache for Redis Basic, Standard, Premium, and Enterprise offerings are
being retired. Microsoft recommends Azure Managed Redis as their successor.
Azure Managed Redis is powered by Redis Enterprise; its current SKU names use
tiers such as `Balanced_B0`, not the retired `Enterprise_*` SKU names.

## Decision Drivers

- Share cache entries across the web app and background workers.
- Keep the cache disposable: the application must continue on a cache miss if
  Redis is unavailable.
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

Provision one Azure Managed Redis instance in each staging and production
subscription. Use the smallest Balanced SKU, `Balanced_B0` (0.5 GB), as the
initial size. Enable high availability in production and disable it in staging,
where cache data is disposable. Reassess the SKU using memory use, evictions,
latency, and connection metrics before scaling.

Disable public network access. Connect through a private endpoint and private
DNS, use TLS on the Redis endpoint, and allow Redis traffic only from the web
app and worker subnets. Use the Enterprise clustering policy to provide a
single endpoint compatible with the existing Rails Redis client. Redis uses
access-key authentication for that client; the connection URL is passed to the
web app and worker as an application setting or secure container environment
variable. Terraform state and access to it must therefore be protected.

Rails uses Redis for `Rails.cache` only when `REDIS_URL` is present. Redis
failures behave as cache misses. Cache entries have a one-hour default expiry
and Redis evicts least-recently-used keys when full. The live app and green slot
use separate cache namespaces. Redis is not used for sessions, persistent data,
or background jobs. Local development and review apps remain unchanged.

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

- Web and worker processes share cache entries across instances.
- Redis outages or evictions can reduce performance but do not make cached data
  authoritative or replace the database.
- Production high availability and private endpoints add cost; staging avoids
  high-availability charges because its cache is disposable.
- The Redis access key is stored in Terraform state and must be treated as a
  secret. Managed identity authentication can be considered separately if the
  Rails Redis client gains suitable token-refresh support.
- The AzureRM upgrade requires careful plan review before applying to existing
  staging and production state.