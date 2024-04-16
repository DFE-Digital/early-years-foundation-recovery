module.exports = function(migration) {

  const question = migration.createContentType('question', {
    name: 'Question',
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

  // the last option has an additional conditional text input
  question.createField('other', {
    name: 'Other',
    type: 'Text',
  })

  // an extra option is appended with an index of zero
  question.createField('or', {
    name: 'Or',
    type: 'Text',
  })

  /*
  - increases the other input to a text area
  - appends an additional textbox
  - replaces options with a textbox
  */
  question.createField('more', {
    name: 'More',
    type: 'Boolean'
  })

  /*
    overrides default
    ======================
    formative and summative are dynamic based off number of correct options
    confidence are hard-coded
    feedback are controlled by content editors
  */
  question.createField('multi_select', {
    name: 'Multi select',
    type: 'Boolean'
  })

  question.createField('skippable', {
    name: 'Skippable',
    type: 'Boolean'
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

  question.changeFieldControl('multi_select', 'builtin', 'boolean', {
    helpText: 'Select multiple options? (default no)',
    trueLabel: 'yes',
    falseLabel: 'no'
  })

  question.changeFieldControl('skippable', 'builtin', 'boolean', {
    helpText: 'Hide once answered?  (default no)',
    trueLabel: 'yes',
    falseLabel: 'no'
  })

  question.changeFieldControl('more', 'builtin', 'boolean', {
    helpText: 'Allow more user input? (default no)',
    trueLabel: 'yes',
    falseLabel: 'no'
  })

}
