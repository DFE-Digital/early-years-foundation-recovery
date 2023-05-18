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

  trainingModule.createField('depends_on', {
    name: 'Depends on',
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

  trainingModule.createField('image', {
    name: 'Image',
    type: 'Link',
    linkType: 'Asset',
    required: true
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

  trainingModule.createField('criteria', {
    name: 'Criteria',
    type: 'Text',
    required: true
  })

  trainingModule.createField('duration', {
    name: 'Duration',
    type: 'Number',
    required: true,
    defaultValue: {
      'en-US': 1,
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
        range: { min: 1 }
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

  trainingModule.changeFieldControl('pages', 'builtin', 'entryLinksEditor', {
    helpText: 'Define module content and order here',
  })

}
