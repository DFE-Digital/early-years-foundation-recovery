module.exports = function(migration) {
	const video = migration
    .createContentType("video", {
      name: "Video",
      displayField: 'name'
    })
  
  const training_module = video.createField('trainingModule', {
    name: 'Training module',
    type: 'Symbol'
  })

  const name = video.createField('name', {
    name: 'Name',
    type: 'Symbol'
  })

  const title = video.createField('title', {
    name: 'Title',
    type: 'Text'
  })
  
  const transcript = video.createField('transcript', {
    name: 'Transcript',
    type: 'Text'
  })
  
  const video_id = video.createField('videoId', {
    name: 'Video ID',
    type: 'Symbol'
  })

  const video_provider = video.createField('videoProvider', {
    name: 'Video Provider',
    type: 'Symbol',
    required: true,
    validations: [
      {
        in: [ 'vimeo', 'youtube' ]
      }
    ]
  })
}
