module.exports = function(migration) {
	const question = migration
    .createContentType("question", {
      name: "Question",
      displayField: 'slug'
    })

  const slug = question.createField('slug', {
    name: 'Slug',
    type: 'Symbol'
  })

  const body = question.createField('body', {
    name: 'Body',
    type: 'Text'
  })
  
  const assessment_succeed = question.createField('assessmentSucceed', {
    name: 'Assessment succeeds summary text',
    type: 'Text'
  })
  
  const assessment_fail = question.createField('assessmentFail', {
    name: 'Assessment fails summary text',
    type: 'Text'
  })
  
  const module_id = question.createField('module_id', {
    name: 'Module ID',
    type: 'Symbol'
  })

  const answers = question.createField('answers', {
    name: 'Answers',
    type: 'Object'
  })
}