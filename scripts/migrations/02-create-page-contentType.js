module.exports = function(migration) {
	const page = migration
    .createContentType("page", {
      name: "Page",
      displayField: 'slug'
    })

  const title = page.createField('title', {
    name: 'Title',
    type: 'Symbol',
    required: true
  })

  const slug = page.createField('slug', {
    name: 'Slug',
    type: 'Symbol'
  })

  const heading = page.createField('heading', {
    name: 'Heading',
    type: 'Text'
  })

  const body = page.createField('body', {
    name: 'Body',
    type: 'Text'
  })
  
  const module_id = page.createField('module_id', {
    name: 'Module ID',
    type: 'Symbol'
  })
  
  const component = page.createField('component', {
    name: 'Component',
    type: 'Symbol'
  })
  
  const notes = page.createField('notes', {
    name: 'Notes',
    type: 'Symbol'
  })
}