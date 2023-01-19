module.exports = function(migration) {
	const confidence = migration
    .createContentType("confidence", {
      name: "Confidence",
      displayField: 'name'
    })

  const name = confidence.createField('name', {
    name: 'Name',
    type: 'Symbol'
  })

  const body = confidence.createField('body', {
    name: 'Body',
    type: 'Text'
  })
  
  const training_module = confidence.createField('trainingModule', {
    name: 'Training module',
    type: 'Symbol'
  })

  const answers = confidence.createField('answers', {
    name: 'Answers',
    type: 'Object'
  })

  const page_numbers = confidence.createField('pageNumbers', {
    name: 'Page numbers',
    type: 'Integer' 
  })

  const total_questions = confidence.createField('totalQuestions', {
    name: 'Total questions',
    type: 'Integer'
  })
}
