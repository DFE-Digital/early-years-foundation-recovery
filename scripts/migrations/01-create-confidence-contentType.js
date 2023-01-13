module.exports = function(migration) {
	const confidence = migration
    .createContentType("confidence", {
      name: "Confidence question",
      displayField: 'slug'
    })

  const slug = confidence.createField('slug', {
    name: 'Slug',
    type: 'Symbol'
  })

  const body = confidence.createField('body', {
    name: 'Body',
    type: 'Text'
  })
  
  const module_id = confidence.createField('module_id', {
    name: 'Module ID',
    type: 'Symbol'
  })

  const answers = confidence.createField('answers', {
    name: 'Answers',
    type: 'Object'
  })
}