class YoutubePage
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module

  validates :heading, :body, :youtube_url, presence: true

  # To display without error the Youtube URL should be the embedded url.
  # On the target video page, click Share and then selected embeded.
  # Use the URL within the embeded code. For example:
  #  https://www.youtube.com/embed/ucjmWjJ25Ho
  #
  validates :youtube_url, format: %r{\Ahttps://www\.youtube\.com/embed}

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
  def video_title
    translate(:video_title)
  end

  # @return [String]
  def youtube_url
    translate(:youtube_url)
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end
end
