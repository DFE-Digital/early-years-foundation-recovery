module.exports = function(migration) {

  const trainingModule = migration.createContentType('trainingModule', {
    name: 'Training Module',
    displayField: 'title',
    description: 'Top-level Model'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  trainingModule.createField('title', {
    name: 'Title',
    type: 'Symbol',
    required: true,
    validations: [
      {
        unique: true
      }
    ]
  })

  trainingModule.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true,
    validations: [
      {
        unique: true
      }
    ]
  })

  trainingModule.createField('image', {
    name: 'Image',
    type: 'Link',
    linkType: 'Asset',
    required: true
  })

  // markdown not permitted
  trainingModule.createField('upcoming', {
    name: 'Upcoming',
    type: 'Text',
    required: true,
    validations: [
      {
        prohibitRegexp: { pattern: '\\n' }
      }
    ]
  })

  // markdown not permitted
  trainingModule.createField('description', {
    name: 'Description',
    type: 'Text',
    required: true,
    validations: [
      {
        prohibitRegexp: { pattern: '\\n' }
      }
    ]
  })

  trainingModule.createField('outcomes', {
    name: 'Skills',
    type: 'Text',
    required: true
  })

  trainingModule.createField('criteria', {
    name: 'Criteria',
    type: 'Text',
    required: true
  })

  // markdown not permitted
  trainingModule.createField('about', {
    name: 'About',
    type: 'Text',
    required: true,
    validations: [
      {
        prohibitRegexp: { pattern: '\\n' }
      }
    ]
  })

  trainingModule.createField('duration', {
    name: 'Duration',
    type: 'Number',
    required: true,
    defaultValue: {
      'en-US': 2,
    },
    validations: [
      {
        range: { min: 0.5, max: 3 }
      }
    ]
  })

  trainingModule.createField('position', {
    name: 'Position',
    type: 'Integer',
    required: true,
    validations: [
      {
        range: { min: 1, max: 9 }
      }
    ]
  })

  trainingModule.createField('pages', {
    name: 'Pages',
    type: 'Array',
    items: {
      type: 'Link',
      linkType: 'Entry',
      validations: [
        {
          linkContentType: [
            'page',
            'question',
            'video'
          ]
        }
      ]
    }
  })

  /* Interface -------------------------------------------------------------- */

  trainingModule.changeFieldControl('title', 'builtin', 'singleLine', {
    helpText: 'Title of module'
  })

  /* markdown */

  trainingModule.changeFieldControl('outcomes', 'builtin', 'markdown', {
    helpText: 'Bullet points which follow on from the sentence "On completion of this module you will be able to:".'
  })

  trainingModule.changeFieldControl('criteria', 'builtin', 'markdown', {
    helpText: 'Bullet points which follow on from the sentence "This module covers:".'
  })

  /* text */

  trainingModule.changeFieldControl('upcoming', 'builtin', 'markdown', {
    helpText: 'A short introduction for a future module'
  })

  trainingModule.changeFieldControl('description', 'builtin', 'multipleLine', {
    helpText: 'A lead in sentence about the content.'
  })

  trainingModule.changeFieldControl('about', 'builtin', 'multipleLine', {
    helpText: 'One or two sentence that describes what the module is about. Usual starts with "This module explores..."'
  })

  /* number */

  trainingModule.changeFieldControl('duration', 'builtin', 'numberEditor', {
    helpText: 'Select number of hours to complete the module.'
  })

  trainingModule.changeFieldControl('position', 'builtin', 'numberEditor', {
    helpText: 'Order of the module.'
  })

  /* linked entries */

  trainingModule.changeFieldControl('image', 'builtin', 'assetLinkEditor', {
    helpText: 'Select thumbnail image.',
  })

  trainingModule.changeFieldControl('pages', 'builtin', 'entryCardsEditor', {
    helpText: 'Define module content and order here.',
  })

}
