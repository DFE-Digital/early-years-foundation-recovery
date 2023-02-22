module.exports = function(migration) {
  const trainingModule = migration.editContentType('trainingModule')

  trainingModule.editField('objective', {
    validations: [
      { 'prohibitRegexp': { 'pattern': '\\n'} }
    ]
  })
}
