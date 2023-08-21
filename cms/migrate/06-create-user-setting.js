module.exports = function(migration) {

  const userSetting = migration.createContentType('userSetting', {
    name: 'Setting',
    displayField: 'title',
    description: 'Learner work setting'
  })

  /* Fields ----------------------------------------------------------------- */

  userSetting.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true,
    validations: [
      { 'unique': true },
    ]
  })

  // displayField
  userSetting.createField('title', {
    name: 'Title',
    type: 'Symbol',
    required: true,
    validations: [
      { 'unique': true },
    ]
  })

  userSetting.createField('local_authority', {
    name: 'Local Authority',
    type: 'Boolean',
    required: true,
    defaultValue: {
      'en-US': true
    }
  })

  userSetting.createField('role_type', {
    name: 'Role',
    type: 'Symbol',
    required: true,
    defaultValue: {
      'en-US': 'none',
    },
    validations: [
      {
        in: ['childminder', 'other', 'none']
      }
    ]
  })
}
