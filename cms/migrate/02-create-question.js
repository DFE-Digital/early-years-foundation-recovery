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
    required: true,
    validations: [
      {
        prohibitRegexp: { pattern: '\\.|\\s|[A-Z]' }
      }
    ]
  })

  // type
  question.createField('page_type', {
    name: 'Page type',
    type: 'Symbol',
    required: true,
    defaultValue: {
      'en-US': 'formative',
    },
    validations: [
      {
        in: [
         'formative',
         'summative',
         'confidence',
        ]
      }
    ]
  })

  question.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true
  })
  
  /*
    Success and failure messages
    =============================
    formative: customise both
    summative: customise failure only (success unused)
    confidence: both use default
  */

  question.createField('success_message', {
    name: 'Success message',
    type: 'Text',
    required: true,
    defaultValue: {
      'en-US': 'Thank you',
    }
  })
  
  question.createField('failure_message', {
    name: 'Failure message',
    type: 'Text',
    required: true,
    defaultValue: {
      'en-US': 'Thank you',
    }
  })
  
  question.createField('answers', {
    name: 'Answers',
    type: 'Object',
  })

  /* Interface -------------------------------------------------------------- */

  /* JSON */

  question.changeFieldControl('answers', 'builtin', 'objectEditor', {
    helpText: '[["Wrong answer"],["Correct answer", true]]',
  })

  /* text */

  question.changeFieldControl('body', 'builtin', 'multipleLine', {
    helpText: 'Insert question.'
  })

  question.changeFieldControl('success_message', 'builtin', 'multipleLine', {
    helpText: 'Displayed after "That’s right" if the user selects the correct answer.'
  })

  question.changeFieldControl('failure_message', 'builtin', 'multipleLine', {
    helpText: 'Displayed after "That’s not quite right" if the user selects the wrong answer.'
  })

  /* number */

  question.changeFieldControl('submodule', 'builtin', 'numberEditor', {
    helpText: 'Select the sub-module number the page belongs to, the second number of the page name.'
  })

  question.changeFieldControl('topic', 'builtin', 'numberEditor', {
    helpText: 'Select the topic number the page belongs to, the third number in the page name.'
  })

}
