/*
https://github.com/contentful/contentful-migration/blob/master/README.md#reference-documentation
*/
module.exports = function(migration) {

  migration.deleteContentType('page')

	const page = migration.createContentType('page', {
    name: 'Page',
    displayField: 'name',
    description: 'formerly YAML module_item'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  page.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true
  })

  // type
  page.createField('page_type', {
    name: 'Page type',
    type: 'Symbol',
    required: true
  })

  // parent
  page.createField('training_module', {
    name: 'Training module',
    type: 'Link',
    linkType: 'Entry',
    validations: [
      {
        linkContentType: [
          'trainingModule'
        ]
      }
    ]
  })

  page.createField('submodule', {
    name: 'Submodule',
    type: 'Integer',
    required: true
  })

  page.createField('topic', {
    name: 'Topic',
    type: 'Integer',
    required: true
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

  // page.deleteField('notes')

  page.createField('notes', {
    name: 'Notes',
    type: 'Boolean',
    required: true,
    defaultValue: {
      'en-US': false
    }
  })

  /* Interface --------------------------------------------------------------
  https://www.contentful.com/developers/docs/extensibility/app-framework/editor-interfaces/

  page.changeFieldControl('notes', 'builtin', 'boolean', {
    helpText: 'Use Learning Log to take notes?',
    trueLabel: 'enable',
    falseLabel: 'disable'
  })
  */

}
