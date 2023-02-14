module.exports = function(migration) {
  const staticPage = migration.editContentType("static")
  
  staticPage.createField('html_title', {
    name: 'HTML page title',
    type: 'Symbol',
    required: true,
  })
  
  staticPage.createField('footer', {
    name: 'Add to footer',
    type: 'Boolean',
    required: true,
  })
}
