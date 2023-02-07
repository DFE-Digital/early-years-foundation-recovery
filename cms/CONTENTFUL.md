# Contentful

**The `demo` should be check for accuracy before relying on test results. Confirm that `depends_on` is set, all content is published.**

```
YAML

Finished in 2 minutes 50.8 seconds (files took 3.33 seconds to load)
551 examples, 0 failures, 10 pending

---

CMS

Finished in 2 minutes 58.2 seconds (files took 3.29 seconds to load)
551 examples, 13 failures, 48 pending
```

- [EY Recovery Service](https://app.contentful.com/spaces/dvmeh832nmjc)
- [API Keys](https://app.contentful.com/spaces/dvmeh832nmjc/api/keys/) can be granted access to specific environments or aliases.
- [Management Tokens](https://app.contentful.com/spaces/dvmeh832nmjc/api/cma_tokens) offer [per-developer](https://app.contentful.com/account/profile/cma_tokens) write access.
- [Environments](https://app.contentful.com/spaces/dvmeh832nmjc/settings/environments) are accessed via aliases called `master` (production), `staging` and `test`. Demo content is used in `RAILS_ENV=development|test`.
- [User roles](https://app.contentful.com/spaces/dvmeh832nmjc/settings/users) Content team (editor), Dev team (admin).


## Tasks

Contentful tasks are namespaced under `eyfs:cms`, list them using `rake --tasks eyfs:cms`.

- `rake eyfs:cms:migrate`  # Run migration files in `./cms/migrate`
- `rake eyfs:cms:seed`     # Populate Contentful entries using YAML

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
- Array (requires items)
- Link (requires linkType)
- ResourceLink (requires allowedResources)


## Preview

[Preview](https://app.contentful.com/spaces/dvmeh832nmjc/settings/content_preview)

**Local**

- **Static Page**: `http://localhost:3000/{entry.fields.name}`
- **Page**: `http://localhost:3000/modules/{entry.linkedBy.fields.name}/content-pages/{entry.fields.name}`
- **Question**: `http://localhost:3000/modules/{entry.linkedBy.fields.name}/questionnaires/{entry.fields.name}`
- **Video**: `http://localhost:3000/modules/{entry.linkedBy.fields.name}/content-pages/{entry.fields.name}`
- **Training Module**: `http://localhost:3000/modules/{entry.fields.name}`
