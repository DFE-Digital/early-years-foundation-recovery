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
    required: true
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
    required: true
  })

  video.createField('topic', {
    name: 'Topic',
    type: 'Integer',
    required: true
  })


  video.createField('title', {
    name: 'Title',
    type: 'Text',
    required: true
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
}
