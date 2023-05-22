module.exports = function(migration) {

  const question = migration.createContentType('question', {
    name: 'Question',
    displayField: 'name',
    description: 'Formative, Summative or Confidence'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  question.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true
  })

  // type
  question.createField('page_type', {
    name: 'Page type',
    type: 'Symbol',
    required: true,
    defaultValue: {
      'en-US': 'formative_questionnaire',
    },
    validations: [
      {
        in: [
         'formative_questionnaire',
         'summative_questionnaire',
         'confidence_questionnaire',
        ]
      }
    ]
  })

  question.createField('training_module', {
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

  question.createField('submodule', {
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

  question.createField('topic', {
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

  question.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true
  })
  
  question.createField('success_message', {
    name: 'Success message',
    type: 'Text',
    required: true
  })
  
  question.createField('failure_message', {
    name: 'Failure message',
    type: 'Text',
    required: true
  })
  
  question.createField('answers', {
    name: 'Answers',
    type: 'Object',
  })


  /* Interface -------------------------------------------------------------- */

  question.changeFieldControl('answers', 'builtin', 'objectEditor', {
    helpText: 'An array of arrays: add true for correct options',
  })

}
