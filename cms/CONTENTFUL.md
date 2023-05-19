# Contentful

## Terminology

- `CMS`: Content Management System.
- `Space`: The Early Years Recovery content, team management, release schedule, mock data for application test, all exist within a space.
- `Alias`: Content in environments is accessed using aliases. The target an alias points to can be changed. We have access to three aliases.
- `Environment`: Content exists within an environment. We have access to four environments.
- `Content model`: The conceptual entities used to author content. Used to define attributes, validations and control the editor interface.
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
- `Review deployment`: A temporary deployment that can use either the Delivery or Preview APIs, demo or genuine content.
- `API`: Application Programming Interface.
- `Delivery API`: The mechanism that returns published content.
- `Preview API`: The mechanism that returns both published and draft content.

**NB: The `demo` environment should be check for accuracy before relying on test results. Confirm that `depends_on` is set, all content is published.**

- [EY Recovery Service](https://app.contentful.com/spaces/dvmeh832nmjc)
- [API Keys](https://app.contentful.com/spaces/dvmeh832nmjc/api/keys/) can be granted access to specific environments or aliases.
- [Management Tokens](https://app.contentful.com/spaces/dvmeh832nmjc/api/cma_tokens) offer [per-developer](https://app.contentful.com/account/profile/cma_tokens) write access.
- [Environments](https://app.contentful.com/spaces/dvmeh832nmjc/settings/environments) are accessed via aliases called `master` (production), `staging` and `test`. Demo content is used in `RAILS_ENV=development|test`.
- [User roles](https://app.contentful.com/spaces/dvmeh832nmjc/settings/users) Content team (editor), Dev team (admin).


## Tasks

Contentful tasks are namespaced under `eyfs:cms`, list them using `rake --tasks eyfs:cms`.

1. Run migration files `rake eyfs:cms:migrate` (from `./cms/migrate`)
2. Populate Contentful entries using YAML `rake eyfs:cms:seed`
3. Validate course content `rake eyfs:cms:validate`

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

For developer use:

**Local**

- **Static Page**: `http://localhost:3000/{entry.fields.name}`
- **Page**: `http://localhost:3000/modules/{entry.linkedBy.fields.name}/content-pages/{entry.fields.name}`
- **Question**: `http://localhost:3000/modules/{entry.linkedBy.fields.name}/questionnaires/{entry.fields.name}`
- **Video**: `http://localhost:3000/modules/{entry.linkedBy.fields.name}/content-pages/{entry.fields.name}`
- **Training Module**: `http://localhost:3000/modules/{entry.fields.name}`

**Development** WIP

For content author use:

**Staging** WIP

## Validations

- https://www.contentful.com/developers/docs/references/content-management-api/#/reference/content-types/content-type
- https://contentful.com/help/available-validations/

## Interface

- https://www.contentful.com/developers/docs/extensibility/app-framework/editor-interfaces/
