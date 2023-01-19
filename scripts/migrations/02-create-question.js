module.exports = function(migration) {
	const question = migration
    .createContentType("question", {
      name: "Question",
      displayField: 'name'
    })
  
  const training_module = question.createField('trainingModule', {
    name: 'Training module',
    type: 'Symbol'
  })

  const name = question.createField('name', {
    name: 'Name',
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
  
  const assessments_type = question.createField('assessmentsType', {
    name: 'Assessments type',
    type: 'Symbol'
  })
  
  const answers = question.createField('answers', {
    name: 'Answers',
    type: 'Object'
  })

  const page_numbers = question.createField('pageNumber', {
    name: 'Page number',
    type: 'Integer'
  })
  
  const total_questions = question.createField('totalQuestions', {
    name: 'Total questions',
    type: 'Integer'
  })
}
