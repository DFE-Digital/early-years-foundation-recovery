# Contentful

**The `demo` environment should be checked for accuracy before relying on test results.**
**Confirm all content is published.**

- [EY Recovery Service](https://app.contentful.com/spaces/dvmeh832nmjc)
- [API Keys](https://app.contentful.com/spaces/dvmeh832nmjc/api/keys/) can be granted access to specific environments or aliases.
- [Management Tokens](https://app.contentful.com/spaces/dvmeh832nmjc/api/cma_tokens) offer [per-developer](https://app.contentful.com/account/profile/cma_tokens) write access.
- [Environments](https://app.contentful.com/spaces/dvmeh832nmjc/settings/environments) are accessed via aliases called `master` (production), `staging` and `test` (CMS training). Demo training content is used in `RAILS_ENV=development|test`.
- [User roles](https://app.contentful.com/spaces/dvmeh832nmjc/settings/users).


## Tasks

Contentful tasks are namespaced under `eyfs:cms`, list them using `rake --tasks eyfs:cms`.

1. Define Contentful entry models
  `rake eyfs:cms:migrate` (from `./cms/migrate`)
2. Upload asset files to Contentful
  `rake eyfs:cms:seed_images`
3. Seed static pages from YAML
  `rake eyfs:cms:seed_static`
4. Seed course content from YAML
  `rake eyfs:cms:seed`
5. Validate CMS content
  `rake eyfs:cms:validate`
6. Search CMS Question JSON fields
  `rake eyfs:cms:search`

## Migrations

<https://github.com/contentful/contentful-migration/blob/master/README.md#reference-documentation>

- Symbol (Short text)
- Text (Long text)
- Integer
- Number
- Date
- Boolean
- Object
- Location
- RichText
- Array (requires items) `pages`
- Link (requires linkType) `depends_on`, `image` and `training_module`
- ResourceLink (requires allowedResources)


## Preview

We will use 3 [preview](https://app.contentful.com/spaces/dvmeh832nmjc/settings/content_preview) buttons.

**Local**

Used by developers when editing module content, usually demo content.

- **Static Page**
  `http://localhost:3000/{entry.fields.name}`
- **Page**
  `http://localhost:3000/modules/{entry.linkedBy.fields.name}/content-pages/{entry.fields.name}`
- **Question**
  `http://localhost:3000/modules/{entry.linkedBy.fields.name}/questionnaires/{entry.fields.name}`
- **Video**
  `http://localhost:3000/modules/{entry.linkedBy.fields.name}/content-pages/{entry.fields.name}`
- **Training Module**
  `http://localhost:3000/modules/{entry.fields.name}`

**Development**

Used by developers when editing demo module content.

As above replace `http://localhost:3000` with `https://ey-recovery-dev.london.cloudapps.digital`

**Staging**

Used by content editors when editing genuine module content.

As above replace `http://localhost:3000` with `https://ey-recovery-staging.london.cloudapps.digital`


## Webhooks

**Common settings**

- Filters: `sys.environment.sys.id` equals `master`
- Headers: Secret `BOT`
- Content type: `application/vnd.contentful.management.v1+json`
- Content length: enabled
- Payload: default

**1. Preview**

- Name: `Edited content for Staging (preview)`
- URL: `POST` to `https://ey-recovery-staging.london.cloudapps.digital/change`
- Content events triggers: `Autosave` of `Entry` or `Asset`
- Other API events: N/A

**2. Release**

- Name: `Published content for Production (delivery)`
- URL: `POST` to `https://ey-recovery.london.cloudapps.digital/release`
- Content events triggers: N/A
- Other API events: `Release` action `Execute`

**3. Standalone Publishing**

- Name: `Publish standalone immediately`
- URL: `POST` to `https://ey-recovery.london.cloudapps.digital/change`
- Filters: `sys.environment.sys.id` equals `master` and `sys.contentType.sys.id` equals `static`
- Content events triggers: `Publish` of `Entry` if `static`
- Other API events: N/A

## Validations

- https://www.contentful.com/developers/docs/references/content-management-api/#/reference/content-types/content-type
- https://contentful.com/help/available-validations/

## Interface

- https://www.contentful.com/developers/docs/extensibility/app-framework/editor-interfaces/

## Terminology

Information for onboarding content editors:

- `CMS`: Content Management System.
- `ERD`: Entity Relationship Diagram. (tbc in UML)
- `Space`: The Early Years Recovery content, team management, release schedule, mock data for application test, all exist within a space.
- `Alias`: Content in environments is accessed using aliases. The target an alias points to can be changed. We have access to three aliases.
- `Environment`: Content exists within an environment. We have access to four environments.
- `Content model`: The entities used to author entries. Used to define attributes, validations and control the editor interface. For example `Training Module`, `Question`
- `Content`: Instances of a content model. Used to create entries.
- `Master content`: The alias used by the public facing website which links to an environment. The environments this can point to can be named, cloned and destroyed by the content team.
- `Staging content`: An alias linking to an environment that can be used for testing, demoing. A potential use for this is when significant changes are made to models and code together.
- `Test content`: The alias used by the developer integration pipeline which links to the demo environment.
- `Demo content`: The environment linked to by the test alias containing a simplified abstraction of course content.
- `Integrity check`: An automated checklist to determine whether module content meets minimum standards.
- `Release`: A scheduled action that publishes a collection of content entries.
- `Launch`: The Contentful product that allows content editors to orchestrate a release.
- `Webhook`: A method of communication used by the CMS to alert a deployed environment that content has changed.
- `Cache`: An automatic snapshot of course content used to speed up pages in the browser.
- `Production deployment`: The public facing application using the current code and published content.
- `Staging deployment`: The latest code release candidate accessing draft content.
- `Development deployment`: The latest code accessing demo content. (currently standing in for production)
- `Review deployment`: A temporary deployment that can use either the Delivery or Preview APIs, demo or genuine content.
- `API`: Application Programming Interface.
- `Delivery API`: The mechanism that returns published content.
- `Preview API`: The mechanism that returns both published and draft content.
