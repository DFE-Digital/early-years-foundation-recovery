# Page model for pages with module_item specific embedded video content
#
class VideoPage < ContentPage
  attr_accessor :video

  validates :video, presence: true

  # @return [String] defaults to placeholder
  def video_title
    translate(:video).fetch(:title, '[Title to be added]')
  end

  # @return [String] defaults to placeholder
  def transcript
    return 'Transcript currently unavailable' unless File.exist?(transcript_file)

    YAML.load_file(transcript_file)['transcript']
  end

  # @return [nil, String]
  def video_url
    return unless video_id

    %(#{video_site}/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
  end

private

  # @return [String]
  def video_provider
    translate(:video)[:provider]
  end

  # @return [String]
  def video_id
    translate(:video)[:id]
  end

  def video_site
    if vimeo?
      'https://player.vimeo.com/video'
    elsif youtube?
      'https://www.youtube.com/embed'
    end
  end

  # @return [Boolean]
  def vimeo?
    video_provider.casecmp?('vimeo')
  end

  # @return [Boolean]
  def youtube?
    video_provider.casecmp?('youtube')
  end

  # @return [String]
  def transcript_file
    Rails.root.join(%(data/video-transcripts/#{video_id}.yml))
  end
end
