module.exports = function(migration) {
  const staticPage = migration.editContentType("static")
  
  staticPage.createField('addToFooter', {
    name: 'Add to footer',
    type: 'Boolean',
    required: true,
  })
}
