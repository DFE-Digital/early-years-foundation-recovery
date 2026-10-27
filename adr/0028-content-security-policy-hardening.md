# Harden Content Security Policy and Introduce Controlled Rollout Mode

* Status: accepted

## Context and Problem Statement

An ITHC finding (5.1.3: Content-Security Policy Misconfigurations) identified that the
application CSP allowed `unsafe-inline` for scripts and styles, used broad/wildcard
allow-lists, and permitted overly broad connection targets. This weakened confidentiality
and integrity protections by increasing the impact of script injection and data exfiltration.

The report recommendations require:

- removing `unsafe-inline`/`unsafe-eval`
- using nonce/hash-based controls
- setting strict explicit directives (including `default-src 'none'`)
- preferring exact host allow-lists
- enabling mixed-content protections
- using report-only first, then enforcing

## Decision Drivers

- Address ITHC 5.1.3 with measurable CSP hardening
- Reduce XSS and exfiltration blast radius
- Preserve production stability during rollout
- Keep an operational fallback without code redeploy

## Considered Options

1. Keep existing CSP and rely on other controls.
2. Enforce strict CSP immediately in all environments with no fallback.
3. Harden CSP and keep a controlled report-only toggle for rollout/incident response.

## Decision Outcome

Chosen option: 3.

We harden CSP by removing permissive directives and adopting nonce-based controls,
including explicit `default-src 'none'`, explicit source directives, and mixed-content
protections (`upgrade-insecure-requests` and `block-all-mixed-content`).

To support safe rollout and operational response, we retain `CSP_REPORT_ONLY` as an
environment toggle:

- `CSP_REPORT_ONLY=true`: report-only mode (evaluate and report, do not block)
- `CSP_REPORT_ONLY=false`: enforce mode (evaluate and block)

Expected steady state is enforced CSP in production (`CSP_REPORT_ONLY=false`).
Report-only in production is temporary and only for rollout diagnostics or break-glass
incident mitigation.

## Consequences

- Security posture improves against inline/script injection abuse paths.
- Some frontend refactoring is required to remove inline styles/scripts that conflict
  with stricter policy.
- Operations gain a reversible runtime switch for controlled rollout and recovery.
- Teams must treat production report-only as temporary and explicitly track reversion
  to enforcement.
