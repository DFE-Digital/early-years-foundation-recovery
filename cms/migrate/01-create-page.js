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
    required: true,
    validations: [
      {
        prohibitRegexp: { pattern: '\\.|\\s|[A-Z]' }
      }
    ]
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
         'topic_intro',
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

  /* text */

  page.changeFieldControl('heading', 'builtin', 'multipleLine', {
    helpText: 'Page heading, h1.',
  })

  /* markdown */

  page.changeFieldControl('body', 'builtin', 'markdown', {
    helpText: 'All page content including sub-headings, bullet points and images.',
  })

  /* number */

  page.changeFieldControl('submodule', 'builtin', 'numberEditor', {
    helpText: 'Select the sub-module number the page belongs to, the second number of the page name.'
  })

  page.changeFieldControl('topic', 'builtin', 'numberEditor', {
    helpText: 'Select the topic number the page belongs to, the third number in the page name.'
  })

  /* toggle */

  page.changeFieldControl('notes', 'builtin', 'boolean', {
    helpText: 'Use Learning Log to take notes?',
    trueLabel: 'enable',
    falseLabel: 'disable'
  })

}
