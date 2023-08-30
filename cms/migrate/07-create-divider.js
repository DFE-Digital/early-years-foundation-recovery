module.exports = function(migration) {

  const divider = migration.createContentType('divider', {
    name: 'Divider',
    // displayField: 'name',
    displayField: 'section_type',
    description: 'Training content separator'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  // divider.createField('name', {
  //   name: 'Name',
  //   type: 'Symbol',
  //   required: true,
  // })

  // type
  divider.createField('section_type', {
    name: 'Section type',
    type: 'Symbol',
    required: true,
    defaultValue: {
      'en-US': 'submodule',
    },
    validations: [
      {
        in: [
         'submodule',
         'topic',
        ]
      }
    ]
  })

}
