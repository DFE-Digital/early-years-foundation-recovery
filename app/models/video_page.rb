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

    transcript_table = Builder::XmlMarkup.new(:indent => 2)
    transcript_table.table(class:"govuk-table") {
      transcript_table.tbody( class:"govuk-table__body")
      transcript_table.tr(class:"govuk-table__row") { transcript_data[0].keys.each { |key| transcript_table.th(key, style:"display: none;")}}
      transcript_data.each { |row| transcript_table.tr(class:"govuk-table__row") { row.values.each { |value| transcript_table.td(value, class:"govuk-table__cell", style:"border:none;")}}}
    }
    return transcript_table
    # transcript_array = transcript_data.map { |hash| hash.to_a}
    # transcript_array = transcript_data.flat_map(&:values)
    # array = transcript_hash.to_a
    # puts "12!@@$@$@$@£$$@$@"
    # puts array
    # transcript_array = transcript_hash.flat_map(&:values)
    # puts "@£$%$£@£$%^^%$£@£$%^"
    # puts transcript_array

    # transcript_array = transcript_hash.map { |key, value| value }
    # binding.pry
    # TODO: iterate and convert to html table
  end

  # @return [ModuleItem]
  def module_item
    @module_item ||= ModuleItem.find_by(training_module: training_module, name: name)
  end
end
