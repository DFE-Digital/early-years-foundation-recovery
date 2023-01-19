module.exports = function(migration) {
	const trainingModule = migration
	    .createContentType("trainingModule", {
	      name: "Training Module",
	      displayField: 'title'
    })

  const title = trainingModule.createField('title', {
    name: 'Title',
    type: 'Symbol',
    required: true
  })

  const depends_on = trainingModule.createField('depends_on', {
    name: 'Depends on',
    type: 'Array',
    items: {
      type: 'Link',
      linkType: 'Entry'
    }
  })

  const name = trainingModule.createField('name', {
	  name: 'Name',
    type: 'Symbol'
  })

  const thumbnail = trainingModule.createField('thumbnail', {
    name: 'Module thumbnail',
    type: 'Link',
    linkType: 'Asset'
  })

  const short_description = trainingModule.createField('short_description', {
    name: 'Short description',
    type: 'Text'
  })

  const description = trainingModule.createField('description', {
    name: 'Description',
    type: 'Text'
  })

  const objective = trainingModule.createField('objective', {
    name: 'Objective',
    type: 'Text'
  })

  const criteria = trainingModule.createField('criteria', {
    name: 'Criteria',
    type: 'Text'
  })

  const duration = trainingModule.createField('duration', {
    name: 'Duration',
    type: 'Number'
  })

  const summative_threshold = trainingModule.createField('summative_threshold', {
    name: 'Summative threshold',
    type: 'Number'
  })

  const pages = trainingModule.createField('pages', {
    name: 'Pages',
    type: 'Array',
    items: {
      type: 'Link',
      validations: [
        {
          linkContentType: [
            'page',
            'question',
            'video'
          ]
        }
      ],
      linkType: 'Entry'
    }
  })
}
