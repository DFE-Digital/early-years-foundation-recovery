module.exports = function(migration) {

  const userSetting = migration.createContentType('course', {
    name: 'Course',
    displayField: 'service_name',
    description: 'Top-level site-wide configuration'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  userSetting.createField('service_name', {
    name: 'Service Name',
    type: 'Symbol',
    required: true
  })

  userSetting.createField('internal_mailbox', {
    name: 'Internal Mailbox',
    type: 'Symbol',
    required: true,
    validations: [
      {
        // email
      }
    ]    
  })

  userSetting.createField('privacy_policy_url', {
    name: 'Privacy policy',
    type: 'Symbol',
    required: true,
    validations: [
      {
        // url
      }
    ]    
  })

  trainingModule.createField('feedback', {
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

}
