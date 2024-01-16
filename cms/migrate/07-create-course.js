module.exports = function(migration) {

  const course = migration.createContentType('course', {
    name: 'Course',
    displayField: 'service_name',
    description: 'Top-level site-wide configuration'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  course.createField('service_name', {
    name: 'Service Name',
    type: 'Symbol',
    required: true
  })

  course.createField('internal_mailbox', {
    name: 'Internal Mailbox',
    type: 'Symbol',
    required: true,
    validations: [
      {
        { 'regexp' : { 'pattern': '^\w[\w.-]*@([\w-]+\.)+[\w-]+$' } }
      }
    ]    
  })

  course.createField('privacy_policy_url', {
    name: 'Privacy policy',
    type: 'Symbol',
    required: true,
    validations: [
      {
        { 'regexp' : { 'pattern': '^(http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-/]))?$' } }
      }
    ]    
  })

  course.createField('feedback', {
    name: 'Feedback Form',
    type: 'Array',
    items: {
      type: 'Link',
      linkType: 'Entry',
      validations: [
        {
          linkContentType: [
            'question'
          ]
        }
      ]
    }
  })

  /* Interface -------------------------------------------------------------- */

  /* linked entries */
  course.changeFieldControl('feedback', 'builtin', 'entryCardsEditor', {
    helpText: 'Define service feedback questions and order here.',
  })

  course.changeFieldControl('privacy_policy_url', 'builtin', 'urlEditor', {
    helpText: 'External privacy policy page',
  })
}
