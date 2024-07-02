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
        prohibitRegexp: { pattern: '\\.|\\s|[A-Z]' }
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

  /* text */

  video.changeFieldControl('heading', 'builtin', 'multipleLine', {
    helpText: 'Page heading, h1.',
  })

  video.changeFieldControl('title', 'builtin', 'multipleLine', {
    helpText: 'Title of video.',
  })

  /* markdown */

  video.changeFieldControl('body', 'builtin', 'markdown', {
    helpText: 'All page content including sub-headings, bullet points and images.',
  })

}
