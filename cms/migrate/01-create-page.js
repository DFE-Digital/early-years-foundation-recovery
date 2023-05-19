module.exports = function(migration) {

	const page = migration.createContentType('page', {
    name: 'Page',
    displayField: 'name',
    description: 'Textual Content'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  page.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true
  })

  // type
  page.createField('page_type', {
    name: 'Page type',
    type: 'Symbol',
    required: true,
    defaultValue: {
      'en-US': 'text_page',
    },
    validations: [
      {
        in: [
         'text_page',
         'interruption_page',
         'sub_module_intro',
         'summary_intro',
         'assessment_intro',
         'confidence_intro',
         'assessment_results',
         'recap_page',
         'certificate',
         'thankyou'
        ]
      }
    ]
  })

  // parent
  page.createField('training_module', {
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

  page.createField('submodule', {
    name: 'Submodule',
    type: 'Integer',
    required: true,
    defaultValue: {
      'en-US': 1,
    },
    validations: [
      {
        range: { min: 1 }
      }
    ]
  })

  page.createField('topic', {
    name: 'Topic',
    type: 'Integer',
    required: true,
    defaultValue: {
      'en-US': 1,
    },
    validations: [
      {
        range: { min: 1 }
      }
    ]
  })

  page.createField('heading', {
    name: 'Heading',
    type: 'Text',
    required: true
  })

  page.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true
  })

  page.createField('notes', {
    name: 'Notes',
    type: 'Boolean',
    required: true,
    defaultValue: {
      'en-US': false
    }
  })

  /* Interface -------------------------------------------------------------- */

  page.changeFieldControl('notes', 'builtin', 'boolean', {
    helpText: 'Use Learning Log to take notes?',
    trueLabel: 'enable',
    falseLabel: 'disable'
  })

}
