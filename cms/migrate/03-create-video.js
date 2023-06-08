module.exports = function(migration) {

	const video = migration.createContentType('video', {
    name: 'Video',
    displayField: 'name',
    description: 'Video Content'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  video.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true,
    validations: [
      {
        prohibitRegexp: { pattern: '\.|\s|[A-Z]' }
      }
    ]
  })

  video.createField('training_module', {
    name: 'Training module',
    required: true,
    type: 'Link',
    linkType: 'Entry',
    validations: [
      {
        linkContentType: [
          'trainingModule'
        ]
      }
    ]
  })

  video.createField('submodule', {
    name: 'Submodule',
    type: 'Integer',
    required: true,
    defaultValue: {
      'en-US': 1,
    },
    validations: [
      {
        range: { min: 0 }
      }
    ]
  })

  video.createField('topic', {
    name: 'Topic',
    type: 'Integer',
    required: true,
    defaultValue: {
      'en-US': 1,
    },
    validations: [
      {
        range: { min: 0 }
      }
    ]
  })

  video.createField('heading', {
    name: 'Heading',
    type: 'Text',
    required: true
  })

  video.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true
  })

  video.createField('title', {
    name: 'Title',
    type: 'Text',
    required: true
  })

  video.createField('transcript', {
    name: 'Transcript',
    type: 'Text',
    required: true
  })
  
  video.createField('video_id', {
    name: 'Video ID',
    type: 'Symbol',
    required: true
  })

  video.createField('video_provider', {
    name: 'Video Provider',
    type: 'Symbol',
    required: true,
    defaultValue: {
      'en-US': 'vimeo',
    },
    validations: [
      {
        in: ['vimeo', 'youtube']
      }
    ]
  })

  /* Interface -------------------------------------------------------------- */

  video.changeFieldControl('heading', 'builtin', 'multipleLine', {
    helpText: 'foo',
  })

  video.changeFieldControl('title', 'builtin', 'multipleLine', {
    helpText: 'Video title is often identical to heading',
  })

}
