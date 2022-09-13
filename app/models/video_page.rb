require "builder/xmlmarkup"

class VideoPage
  include ActiveModel::Validations
  include ActiveModel::Model
  include TranslateFromLocale

  attr_accessor :id, :name, :type, :training_module, :video

  validates :heading, :body, presence: true

  # To display without error the Youtube URL should be the embedded url.
  # On the target video page, click Share and then selected embeded.
  # Use the URL within the embeded code. For example:
  #  https://www.youtube.com/embed/ucjmWjJ25Ho
  #
  # validates :youtube_url, format: %r{\Ahttps://www\.youtube\.com/embed}

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
    translate(:video)[:title]
  end

  # @return [String]
  def video_provider
    translate(:video)[:provider]
  end

  # @return [String]
  def transcript
    video_transcript_id = translate(:video)[:id]
    transcript_file = Rails.root.join(%(data/video-transcripts/#{video_transcript_id}.yml))
    transcript_data = YAML.load_file(transcript_file)
    hasharray_to_html(transcript_data)
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end

  # @return [Html]
  def hasharray_to_html(data)
    transcript_table = Builder::XmlMarkup.new(:indent => 2)
    transcript_table.table(class:"govuk-table") {
      transcript_table.tbody(class:"govuk-table__body first-column-bold")
      transcript_table.tr(class:"govuk-table__row") { data[0].keys.each { |key| transcript_table.th(key, class:"govuk-!-display-none")}}
      data.each { |row| transcript_table.tr(class:"govuk-table__row") { row.values.each { |value| transcript_table.td(value, class:"govuk-table__cell remove-borders")}}}
    }
    return transcript_table
  end
end
