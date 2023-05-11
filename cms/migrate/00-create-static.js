/*
https://github.com/contentful/contentful-migration/blob/master/README.md#reference-documentation

module.exports = function(migration) {

  const trainingModule = migration.editContentType('trainingModule')

  trainingModule.editField('objective', {
    validations: [
      { 'prohibitRegexp': { 'pattern': '\\n'} }
    ]
  })

  const page = migration.editContentType('page')

  page.deleteField('notes')

  migration.deleteContentType('question')
}

*/
module.exports = function(migration) {

  const staticPage = migration.createContentType('static', {
    name: 'Static',
    displayField: 'name',
    description: 'Stand alone pages'
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

  staticPage.createField('body', {
    name: 'Body',
    type: 'Text',
    required: true,
  })

  staticPage.createField('footer', {
    name: 'Add to footer',
    type: 'Boolean',
    required: true,
    defaultValue: {
      'en-US': false
    }
  })

  staticPage.changeFieldControl('name', 'builtin', 'slugEditor', {
    helpText: 'Unique page slug',
  })

}
