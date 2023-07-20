module.exports = function(migration) {

  const staticPage = migration.createContentType('resource', {
    name: 'Resource',
    displayField: 'name',
    description: 'microcopy snippet'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  staticPage.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true,
    validations: [
      { 'unique': true },
      { 'regexp' : { 'pattern': '^[a-z\\.]*$'}}
    ]
  })

  staticPage.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true,
  })

}
