# Cookie `SameSite` policy

* Status: accepted

## Context and Problem Statement
Rails' `config.action_dispatch.cookies_same_site_protection` controls the default `SameSite` attribute on cookies the application sets, including the session cookie used to authenticate users. 

CodeQL flagged the preview environment's use of `:none` as a potential CSRF risk and asked whether `:strict` could be applied across the board.

## Decision Drivers
* Must not break GOV.UK One Login sign-in.
* Must not break Contentful Live Preview.
* Cookies must always be `Secure` (already enforced via `config.force_ssl = true`).
* CSRF is already mitigated by Rails' built-in authenticity token (`protect_from_forgery`).

## Considered Options
* `:strict` everywhere — breaks GOV.UK One Login (state/nonce not sent on callback) and Notify email links, and breaks Contentful Live Preview.
* `:lax` everywhere — breaks Contentful Live Preview in the preview environment.
* `:none` everywhere — unnecessarily relaxes the live environment's default.
* Environment-specific policy: Rails default (`:lax`) on live, `:none` on the preview environment only.

## Decision Outcome
Keep the environment-specific policy already in place:

* **Live / production** (`CONTENTFUL_PREVIEW=false`): use the Rails 7 default of `:lax`. This is required for the GOV.UK One Login OAuth callback.
* **Preview** (`CONTENTFUL_PREVIEW=true`): set `:none` so the session cookie is sent when the app is loaded inside the Contentful Live Preview.

Risk for the preview environment is mitigated by:
* `Secure` flag enforced via `config.force_ssl = true`.
* Rails CSRF tokens continuing to protect state-changing requests independently of `SameSite`.
* The preview environment serving content editors only, not end users.