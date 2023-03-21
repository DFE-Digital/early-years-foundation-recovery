module.exports = function(migration) {
  const staticPage = migration.editContentType('static')
  
  staticPage.createField('footer', {
    name: 'Add to footer',
    type: 'Boolean',
    required: true,
    defaultValue: {
      'en-US': false
    }
  })
}
