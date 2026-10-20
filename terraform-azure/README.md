# Azure Root Module

This module provisions a new Azure Resource Group that assembles together the infrastructure for hosting the web application.

## Prerequisites
* The [Remote State module](./terraform-azure-remote-state/README.md) must first be applied **independently** before this configuration can be used.

## Terraform And Provider Versions

Use Terraform 1.12.2 (the CI version) and AzureRM 4.67.0. AzureRM was upgraded
from 3.71.0 to support Azure Managed Redis. Set `ARM_SUBSCRIPTION_ID` when
running locally; the deployment workflows already supply it through OIDC.
Terraform explicitly registers only `Microsoft.Cache` in each subscription;
the deployment identity needs permission to register Azure resource providers.

Run `terraform init -upgrade` and review a plan for each environment before
applying the provider upgrade. Existing resources must not be unexpectedly
replaced. The PostgreSQL server explicitly retains private-only network access.
The independent remote-state module is not part of this provider upgrade.

## Redis Cache

Staging and production use [Azure Managed Redis](https://learn.microsoft.com/en-us/azure/redis/overview),
Microsoft's recommended successor to Azure Cache for Redis. Azure manages the
Redis engine version and maintenance. No Redis resources or connection settings
are created for development or review apps, and local development is unchanged.

The default `redis_sku_name` is `Balanced_B0` (0.5 GB), the smallest available
Managed Redis SKU. Production enables high availability; staging disables it
to reduce costs and can lose its disposable cache during maintenance or failure.
There is one instance per environment, shared by web workers and background jobs.
The green deployment slot uses a separate key namespace to avoid sharing cached
content with its separate database. Increase `redis_sku_name` only after checking
memory use, evictions, latency, and connection counts. SKU and HA changes may
require replacement; always inspect the plan.

Budget for the cache, a private endpoint and private DNS in each environment.
No geo-replication, persistence, optional modules, or extra slot instance is
provisioned. Confirm regional SKU availability and the monthly estimate in the
[Azure pricing calculator](https://azure.microsoft.com/en-gb/pricing/calculator/)
using the subscription's negotiated rates before applying.

Public access is disabled. Clients use TLS on port 10000 through a private
endpoint in subnet `172.1.4.0/28`; its NSG permits only the existing web and
worker subnets. Private DNS resolves the normal Managed Redis hostname.
Enterprise clustering provides a single endpoint compatible with Rails'
Redis client, including multi-key cache reads and writes.

Terraform supplies `REDIS_URL` and `CACHE_NAMESPACE` to App Service and its slot.
The staging/production worker deployment reads the live app settings and passes
them as secure container environment variables, so no additional GitHub secrets
are required. Apply Terraform **before deploying the updated application**.
Access-key authentication is explicitly enabled for the existing Rails client;
keys are sensitive Terraform state and App Service settings. Restrict access to
both. Microsoft recommends managed-identity authentication where supported;
adopting it here would also require token refresh support in the Rails client.

Rails uses a one-hour default TTL (call sites can override it), compression,
and short connection/read/write timeouts. Redis evicts least-recently-used keys
when full. Connection errors fall back to cache misses rather than breaking
requests. This is a disposable application cache, not a session or job store;
sessions and the PostgreSQL-backed Que job queue are unchanged.

After deployment, check from the App Service console:

```sh
bundle exec rails runner 'Rails.cache.write("redis-smoke", "ok", expires_in: 60); abort "Redis cache failed" unless Rails.cache.read("redis-smoke") == "ok"; Rails.cache.delete("redis-smoke")'
```
