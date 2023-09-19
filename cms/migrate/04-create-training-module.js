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

  trainingModule.createField('short_description', {
    name: 'Short description',
    type: 'Text',
    required: true
  })

  trainingModule.createField('description', {
    name: 'Description',
    type: 'Text',
    required: true
  })

  trainingModule.createField('criteria', {
    name: 'Criteria',
    type: 'Text',
    required: true
  })

  // markdown not permitted
  trainingModule.createField('objective', {
    name: 'Objective',
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

  trainingModule.createField('summative_threshold', {
    name: 'Summative threshold',
    type: 'Integer',
    required: true,
    defaultValue: {
      'en-US': 70,
    },
    validations: [
      {
        range: { min: 1, max: 100 }
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

  trainingModule.changeFieldControl('description', 'builtin', 'markdown', {
    helpText: 'A lead in sentence about the content. Followed by "On completion of this module you will be able to:" then add bullet points.'
  })

  trainingModule.changeFieldControl('criteria', 'builtin', 'markdown', {
    helpText: 'Bullet points which follow on from the sentence "This module covers:".'
  })

  trainingModule.changeFieldControl('short_description', 'builtin', 'markdown', {
    helpText: 'Title of module'
  })

  /* text */

  trainingModule.changeFieldControl('objective', 'builtin', 'multipleLine', {
    helpText: 'One or two sentence that describes what the module is about. Usual starts with "This module explores..."'
  })

  /* number */

  trainingModule.changeFieldControl('duration', 'builtin', 'numberEditor', {
    helpText: 'Select number of hours to complete the module.'
  })

  trainingModule.changeFieldControl('position', 'builtin', 'numberEditor', {
    helpText: 'Order of the module.'
  })

  trainingModule.changeFieldControl('summative_threshold', 'builtin', 'numberEditor', {
    helpText: 'Percentage required to pass assessment.'
  })

  /* linked entries */

  trainingModule.changeFieldControl('depends_on', 'builtin', 'entryLinkEditor', {
    helpText: 'Leave blank if you don’t have to have completed a previous module to start this module.',
  })

  trainingModule.changeFieldControl('image', 'builtin', 'assetLinkEditor', {
    helpText: 'Select thumbnail image.',
  })

  trainingModule.changeFieldControl('pages', 'builtin', 'entryCardsEditor', {
    helpText: 'Define module content and order here.',
  })

}
