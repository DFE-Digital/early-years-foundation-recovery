module.exports = function(migration) {

  const question = migration.createContentType('question_test', {
    name: 'Question test',
    displayField: 'name',
    description: 'Formative, Summative, Confidence or Feedback'
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
         'feedback',
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
    feedback: both use default
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

  /* Feedback Only ---------------------------------------------------------- */

  question.createField('other', {
    name: 'Other',
    type: 'Text',
  })

  question.createField('or', {
    name: 'Or',
    type: 'Text',
  })

  question.createField('hint', {
    name: 'Hint',
    type: 'Text',
  })

  /*
    overrides default
    ======================
    formative and summative are dynamic based off number of correct options
    confidence are hard-coded
    feedback are more nuanced
  */
  question.createField('response_type', {
    name: 'Feedback response type',
    type: 'Symbol',
  })

  question.createField('skippable', {
    name: 'One-off question',
    type: 'Boolean',
    required: true,
    defaultValue: {
      'en-US': false
    }
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

  /* toggle */

  question.changeFieldControl('skippable', 'builtin', 'boolean', {
    helpText: 'Hide once answered?',
    trueLabel: 'yes',
    falseLabel: 'no'
  })


}
