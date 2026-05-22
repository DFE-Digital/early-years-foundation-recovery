# Serve govuk-frontend assets statically and disable runtime asset compilation

* Status: accepted

## Context and Problem Statement

Production had `config.assets.compile = true` from day one, with a comment
explaining why: *"govuk css contains fixed paths to assets without digests"*.
Compiling at request time is inefficient and expensive, but it was
the quickest way to get things working and never got revisited.

The hard-coded `/assets/...` URLs in the compiled CSS came from four places:

* `govuk-frontend`'s `$govuk-assets-path` (default `/assets/`), used for the
  crest, opengraph and other frontend images;
* `@fortawesome/fontawesome-free`'s `$fa-font-path`, which `app/assets/stylesheets/icons.scss`
  previously set to `/assets/fonts` so the FA webfonts (`fa-solid-900.woff2`
  etc.) could be served by Sprockets at runtime;
* an inline `content: url(/assets/dfe-logo-alt.png)` in `header.scss`;
* a relative `url('icon-print@1x.png')` in `print.scss`.


## Decision Drivers

* Stop using `config.assets.compile = true` in production.
* Keep `govuk-frontend` and `@fortawesome/fontawesome-free` upgrades to a `yarn upgrade`.
* Keep digests on `application.css` / `application.js` and on app-owned images
  referenced via Rails helpers (`image_tag`, `favicon_link_tag`, `image_path`).
* No new asset host or CDN — keep serving from the Rails app on App Service.

## Considered Options

* **Status quo.** Not chosen.
* **Override `$govuk-assets-path` / `$fa-font-path` and serve those assets
  from `public/`.** Chosen.

## Decision Outcome

Override `$govuk-assets-path` to `/govuk-assets/` and `$fa-font-path` to
`/govuk-assets/fonts`, then have `yarn` run copy:assets to populate 
`public/govuk-assets/` from `node_modules/govuk-frontend/dist/govuk/assets/{images,fonts}`
and `node_modules/@fortawesome/fontawesome-free/webfonts`.

The two CSS only app images move to `public/static-images/` and are referenced
as `/static-images/...` from `header.scss` and `print.scss`. Those are tracked
in git because they are app-owned, not vendored.

Sprockets still fingerprints everything else, and `config.assets.compile = false`
in production.
