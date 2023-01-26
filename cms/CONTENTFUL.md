# Contentful

- [EY Recovery Service](https://app.contentful.com/spaces/dvmeh832nmjc)
- [API Keys](https://app.contentful.com/spaces/dvmeh832nmjc/api/keys/) can be granted access to specific environments or aliases.
- [Management Tokens](https://app.contentful.com/spaces/dvmeh832nmjc/api/cma_tokens) offer [per-developer](https://app.contentful.com/account/profile/cma_tokens) write access.
- [Environments](https://app.contentful.com/spaces/dvmeh832nmjc/settings/environments) are accessed via aliases called `master` (production), `staging` and `test`. Demo content is used in `RAILS_ENV=development|test`.
- [User roles](https://app.contentful.com/spaces/dvmeh832nmjc/settings/users) Content team (editor), Dev team (admin).


## Tasks

Contentful tasks are namespaced under `eyfs:cms`, list them using `rake --tasks eyfs:cms`.

- `rake eyfs:cms:migrate`  # Run migration files in `./cms/migrate`
- `rake eyfs:cms:upload`   # Populate Contentful entries using YAML


## Migrations

<https://github.com/contentful/contentful-migration/blob/master/README.md#reference-documentation>

1. define child models (Page, Question, Video)
2. define parent model (Training Module) - which links to children


Symbol (Short text)
Text (Long text)
Integer
Number
Date
Boolean
Object
Location
RichText
Array (requires items)
Link (requires linkType)
ResourceLink (requires allowedResources)


## Preview

[Preview](https://app.contentful.com/spaces/dvmeh832nmjc/settings/content_preview)

Local

- **Page**: `http://localhost:3000/modules/{entry.fields.module_id}/content-pages/{entry.fields.name}`
- **Question**: `http://localhost:3000/modules/{entry.fields.module_id}/questionnaires/{entry.fields.name}`
- **Video**: `http://localhost:3000/modules/{entry.fields.module_id}/content-pages/{entry.fields.name}`
- **Training Module**: `http://localhost:3000/modules/{entry.fields.name}`
