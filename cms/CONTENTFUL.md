# Contentful

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
