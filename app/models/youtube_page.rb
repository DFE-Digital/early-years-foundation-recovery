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
  validates :youtube_url, format: /\Ahttps:\/\/www\.youtube\.com\/embed/

  def heading
    translate(:heading)
  end

  def body
    translate(:body)
  end

  def video_title
    translate(:video_title)
  end

  def youtube_url
    translate(:youtube_url)
  end
end
