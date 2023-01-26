module.exports = function(migration) {

  migration.deleteContentType('trainingModule')

  const trainingModule = migration.createContentType('trainingModule', {
    name: 'Training Module',
    displayField: 'title'
  })

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

  trainingModule.createField('name', {
	  name: 'Name',
    type: 'Symbol',
    validations: [
      {
        unique: true
      }
    ]
  })

  trainingModule.createField('thumbnail', {
    name: 'Thumbnail image',
    type: 'Link',
    linkType: 'Asset'
  })

  trainingModule.createField('short_description', {
    name: 'Short description',
    type: 'Text'
  })

  trainingModule.createField('description', {
    name: 'Description',
    type: 'Text'
  })

  trainingModule.createField('objective', {
    name: 'Objective',
    type: 'Text'
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
    type: 'Number'
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
