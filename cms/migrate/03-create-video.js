module.exports = function(migration) {

  migration.deleteContentType('video')

	const video = migration.createContentType('video', {
    name: 'Video',
    displayField: 'name',
    description: 'formerly YAML module_item (with video)'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  video.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true
  })

  // type
  video.createField('page_type', {
    name: 'Page type',
    type: 'Symbol',
    required: true
  })

  video.createField('training_module', {
    name: 'Training module',
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
    type: 'Text'
  })
  
  video.createField('heading', {
    name: 'Heading',
    type: 'Text'
  })

  video.createField('body', {
    name: 'Body',
    type: 'Text'
  })
  
  video.createField('transcript', {
    name: 'Transcript',
    type: 'Text'
  })
  
  video.createField('video_id', {
    name: 'Video ID',
    type: 'Symbol'
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
