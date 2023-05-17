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
    validations: [
      {
        in: [
         // 'interruption_page',
         // 'sub_module_intro',
         // 'text_page',
         // 'video_page',
         'formative_questionnaire',
         // 'summary_intro',
         // 'recap_page',
         // 'assessment_intro',
         'summative_questionnaire',
         // 'assessment_results',
         // 'confidence_intro',
         'confidence_questionnaire',
         // 'thankyou',
         // 'certificate'
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
        range: { min: 1 }
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
        range: { min: 1 }
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


  /* Interface --------------------------------------------------------------
  https://www.contentful.com/developers/docs/extensibility/app-framework/editor-interfaces/
  */

  question.changeFieldControl('answers', 'builtin', 'objectEditor', {
    helpText: 'An array of arrays: add true for correct options',
  })

}
