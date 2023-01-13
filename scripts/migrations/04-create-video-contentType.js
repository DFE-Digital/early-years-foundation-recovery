module.exports = function(migration) {
	const video = migration
    .createContentType("video", {
      name: "Video",
      displayField: 'slug'
    })

  const slug = video.createField('slug', {
    name: 'Slug',
    type: 'Symbol'
  })

  const transcript = video.createField('transcript', {
    name: 'transcript',
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