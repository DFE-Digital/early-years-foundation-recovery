# Page model for pages with module_item specific embedded video content
#
class VideoPage < ContentPage
  attr_accessor :video

  validates :video, presence: true

  # @return [String]
  def video_id
    translate(:video)[:id]
  end

  # @return [String]
  def video_provider
    translate(:video)[:provider]
  end

  # @return [String] defaults to placeholder
  def video_title
    translate(:video).fetch(:title, '[Title to be added]')
  end

  # @return [String] defaults to placeholder
  def transcript
    return 'Transcript currently unavailable' unless File.exist?(transcript_file)

    YAML.load_file(transcript_file)['transcript']
  end

  # @return [String]
  def vimeo_url
    %(https://player.vimeo.com/video/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
  end

  # @return [String]
  def youtube_url
    %(https://www.youtube.com/embed/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
  end

  # @return [Boolean]
  def vimeo_video?
    video_provider.casecmp?('vimeo')
  end

  # @return [Boolean]
  def youtube_video?
    video_provider.casecmp?('youtube')
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  private

  # @return [String]
  def transcript_file
    Rails.root.join(%(data/video-transcripts/#{video_id}.yml))
  end
end
