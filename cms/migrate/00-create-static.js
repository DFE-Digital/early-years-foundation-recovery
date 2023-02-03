module.exports = function(migration) {

  migration.deleteContentType('static')

  const staticPage = migration.createContentType('static', {
    name: 'Static',
    displayField: 'name',
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  staticPage.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true,
    validations: [
      { 'unique': true },
      { 'regexp' : { 'pattern': '^[a-z-]*$'}}
    ]
  })

  staticPage.createField('heading', {
    name: 'Heading',
    type: 'Symbol',
    required: true,
  })
  
  staticPage.createField('subheading', {
    name: 'Subheading',
    type: 'Text',
  })
  
  staticPage.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true,
  })
}
