module.exports = function(migration) {
	const trainingModule = migration
    .createContentType("trainingModule", {
      name: "Training Module",
      description: "Department for Education Child Development Training Module",
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

  const slug = trainingModule.createField('slug', {
    name: 'Slug',
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

  const duration = trainingModule.createField('duration', {
    name: 'Duration',
    type: 'Number'
  })

  const summative_threshold = trainingModule.createField('summative_thresh', {
    name: 'Summative threshold',
    type: 'Number'
  })

  const pages = trainingModule.createField('pages', {
    name: 'Content pages for this course module',
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

  const summative_assessment = trainingModule.createField('summativeAssessment', {
    name: 'Summative assessment',
    type: 'Array',
    items: {
      type: 'Link',
      validations: [
        {
          linkContentType: [
            'question'
          ]
        }
      ],
      linkType: 'Entry'
    }
  })
  
  const confidence_assessment = trainingModule.createField('confidenceAssessment', {
    name: 'Confidence assessment',
    type: 'Array',
    items: {
      type: 'Link',
      validations: [
        {
          linkContentType: [
            'confidence'
          ]
        }
      ],
      linkType: 'Entry'
    }
  })
}