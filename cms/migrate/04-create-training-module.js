module.exports = function(migration) {

  const trainingModule = migration.createContentType('trainingModule', {
    name: 'Training Module',
    displayField: 'title',
    description: 'Top-level Model'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  trainingModule.createField('title', {
    name: 'Title',
    type: 'Symbol',
    required: true,
    validations: [
      {
        unique: true
      }
    ]
  })

  trainingModule.createField('depends_on', {
    name: 'Depends on',
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

  trainingModule.createField('image', {
    name: 'Image',
    type: 'Link',
    linkType: 'Asset'
  })

  trainingModule.createField('name', {
	  name: 'Name',
    type: 'Symbol',
    validations: [
      {
        unique: true
      }
    ]
  })

  trainingModule.createField('short_description', {
    name: 'Short description',
    type: 'Text'
  })

  trainingModule.createField('description', {
    name: 'Description',
    type: 'Text'
  })

  // markdown not permitted
  trainingModule.createField('objective', {
    name: 'Objective',
    type: 'Text',
    validations: [
      { 'prohibitRegexp': { 'pattern': '\\n'} }
    ]
  })

  trainingModule.createField('criteria', {
    name: 'Criteria',
    type: 'Text'
  })

  trainingModule.createField('duration', {
    name: 'Duration',
    type: 'Number'
  })

  trainingModule.createField('summative_threshold', {
    name: 'Summative threshold',
    type: 'Integer'
  })

  trainingModule.createField('position', {
    name: 'Position',
    type: 'Integer'
  })

  trainingModule.createField('pages', {
    name: 'Pages',
    type: 'Array',
    items: {
      type: 'Link',
      linkType: 'Entry',
      validations: [
        {
          linkContentType: [
            'page',
            'question',
            'video'
          ]
        }
      ]
    }
  })

  /* Interface --------------------------------------------------------------
  https://www.contentful.com/developers/docs/extensibility/app-framework/editor-interfaces/
  */

  trainingModule.changeFieldControl('pages', 'builtin', 'entryLinksEditor', {
    helpText: 'Define module content and order here',
  })

}
