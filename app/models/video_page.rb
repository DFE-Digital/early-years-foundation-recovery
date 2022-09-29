class VideoPage
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module, :video

  validates :heading, :body, :video, presence: true

  # To display without error the Youtube URL should be the embedded url.
  # On the target video page, click Share and then selected embeded.
  # Use the URL within the embedded code. For example:
  #  https://www.youtube.com/embed/ucjmWjJ25Ho
  #

  # @return [Hash]
  delegate :pagination, to: :module_item

  # @return [String]
  def heading
    translate(:heading)
  end

  # @return [String]
  def body
    translate(:body)
  end

  # @return [String]
  def video_id
    translate(:video)[:id]
  end

  # @return [String]
  def video_title
    if translate(:video)[:title].nil?
      '[Title to be added]'
    else
      translate(:video)[:title]
    end
  end

  # @return [String]
  def video_provider
    translate(:video)[:provider]
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

  # @return [String]
  def transcript
    if File.exist?(Rails.root.join(%(data/video-transcripts/#{video_id}.yml)))
      transcript_file = Rails.root.join(%(data/video-transcripts/#{video_id}.yml))
      transcript_data = YAML.load_file(transcript_file)
      transcript_data['transcript']
    else
      'Transcript currently unavailable'
    end
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end
end
