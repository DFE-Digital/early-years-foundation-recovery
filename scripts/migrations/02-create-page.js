module.exports = function(migration) {
	const page = migration.createContentType("page", {
	      name: "Page",
	      displayField: 'name'
	    })

  const name = page.createField('name', {
    name: 'Name',
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
  
  const training_module = page.createField('trainingModule', {
    name: 'Training module',
    type: 'Symbol'
  })
  
  const page_type = page.createField('pageType', {
    name: 'Page type',
    type: 'Symbol'
  })
  
  const notes = page.createField('notes', {
    name: 'Notes',
    type: 'Boolean'
  })
}
