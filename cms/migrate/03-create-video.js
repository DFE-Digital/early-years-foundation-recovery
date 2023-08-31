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

  /* linked entries */

  video.changeFieldControl('training_module', 'builtin', 'entryLinkEditor', {
    helpText: 'Select the module the page belongs to from "Add existing content".',
  })

  /* text */

  video.changeFieldControl('heading', 'builtin', 'multipleLine', {
    helpText: 'Page heading, h1.',
  })

  video.changeFieldControl('title', 'builtin', 'multipleLine', {
    helpText: 'Title of video.',
  })

  /* number */

  video.changeFieldControl('submodule', 'builtin', 'numberEditor', {
    helpText: 'Select the sub-module number the page belongs to, the second number of the page name.'
  })

  video.changeFieldControl('topic', 'builtin', 'numberEditor', {
    helpText: 'Select the topic number the page belongs to, the third number in the page name.'
  })

  /* markdown */

  video.changeFieldControl('body', 'builtin', 'markdown', {
    helpText: 'All page content including sub-headings, bullet points and images.',
  })

}
