module.exports = function(migration) {

  migration.deleteContentType('question')

  const question = migration.createContentType('question', {
    name: 'Question',
    displayField: 'name'
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
    type: 'Integer'
  })

  question.createField('topic', {
    name: 'Topic',
    type: 'Integer'
  })

  question.createField('name', {
    name: 'Name',
    type: 'Symbol'
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
  
  // summative or confidence (formative to be deprecated)
  question.createField('assessments_type', {
    name: 'Assessment type',
    type: 'Symbol'
  })
  
  question.createField('answers', {
    name: 'Answers',
    type: 'Object'
  })

  // Pagination
  question.createField('page_number', {
    name: 'Page number',
    type: 'Integer'
  })
  
  // Pagination
  question.createField('total_questions', {
    name: 'Total questions',
    type: 'Integer'
  })
}
