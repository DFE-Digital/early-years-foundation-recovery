module.exports = function(migration) {

  migration.deleteContentType('question')

  const question = migration.createContentType('question', {
    name: 'Question',
    displayField: 'name'
  })

  /* Fields ----------------------------------------------------------------- */

  // displayField
  question.createField('name', {
    name: 'Name',
    type: 'Symbol',
    required: true
  })

  // type
  question.createField('page_type', {
    name: 'Page type',
    type: 'Symbol',
    required: true
  })

  /*
    can be derived from "page_type"
    TO BE DEPRECATED
  */
  question.createField('assessments_type', {
    name: 'Assessment type',
    type: 'Symbol',
    required: true
  })

  question.createField('training_module', {
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

  question.createField('submodule', {
    name: 'Submodule',
    type: 'Integer',
    required: true
  })

  question.createField('topic', {
    name: 'Topic',
    type: 'Integer',
    required: true
  })

  /*
    duplicate of name
    TO BE DEPRECATED
  */
  question.createField('heading', {
    name: 'Heading',
    type: 'Text',
    required: true
  })

  question.createField('body', {
    name: 'Body',
    type: 'Text'
  })
  
  question.createField('assessment_succeed', {
    name: 'Assessment succeeds summary text',
    type: 'Text'
  })
  
  question.createField('assessment_fail', {
    name: 'Assessment fails summary text',
    type: 'Text'
  })
  
  question.createField('answers', {
    name: 'Answers',
    type: 'Object'
  })
}
