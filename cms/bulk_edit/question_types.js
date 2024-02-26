module.exports = function(migration) {

  const course = migration.createContentType('course', {
    name: 'Course',
    displayField: 'service_name',
    description: 'Top-level site-wide configuration'
  })
}