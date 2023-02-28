# return a boolean to tell us whether the training modules in Contentful all have the
# correct characterisitics

class ContentfulDataIntegrity
  extend Dry::Initializer
  # extend Dry::Core::Cache

  option :environment, default: proc { 'demo' }
  option :training_module, default: proc { 'alpha' }
  # option :cached, default: proc { true }

  def valid?
    raise 'Module does not exist' if find_module_by_name.nil?

    {
      has_video_page?: 'Does not contain video page',
      has_assessment_results?: 'Does not have assessments results page',
      first_page_is_interruption?: 'First page is not interruption page',
      second_page_is_sub_module_intro?: 'Second page is not submodule intro',
      penultimate_page_is_thankyou?: 'Penultimate page is not thank you',
      last_page_is_certificate?: 'Last page is not certificate',
      has_ten_summative_questions?: 'Does not have ten summative questions',
      consecutive_submodules_start_at_one?: "Submodules aren't consecutive or don't start with 1",
      consecutive_topics_start_at_one?: "Topics aren't consecutive or don't start with 1",
    }.each do |method, message|
      unless send(method)
        Rails.logger.debug message
        return false
      end
    end

    true
  end

  # ------------------- Correct page order ---------------------

  # @param input [Array] integers
  # @return [Boolean]
  def consecutive_nums_start_at_one?(input)
    input.each_cons(2).all? { |a, b| b == a + 1 } && input.first == 1
  end

  # @return [Boolean]
  def consecutive_submodules_start_at_one?
    submodule_nums = find_module_by_name.content_by_submodule.keys
    consecutive_nums_start_at_one?(submodule_nums)
  end

  # @return [Boolean]
  def consecutive_topics_start_at_one?
    topic_nums = find_module_by_name.content_by_submodule_topic.keys.group_by(&:first)

    topic_nums.each do |_submodule_num, submod_topic_num|
      return false unless consecutive_nums_start_at_one?(submod_topic_num.map(&:second))
    end

    true
  end

  def find_module_by_name
    # caching twice if used like this
    #
    # fetch_or_store(training_module) do
    #   Training::Module.by_name(training_module)
    # end

    Training::Module.by_name(training_module)
  end

private

  # ------------------- Required page types ---------------------

  def has_video_page?
    find_module_by_name.content.any?(Training::Video)
  end

  def has_assessment_results?
    find_module_by_name.content.map(&:page_type).any?('assessment_results')
  end

  def first_page_is_interruption?
    find_module_by_name.content.first.page_type.eql?('interruption_page')
  end

  def second_page_is_sub_module_intro?
    find_module_by_name.content[1].page_type.eql?('sub_module_intro')
  end

  def penultimate_page_is_thankyou?
    find_module_by_name.content[-2].page_type.eql?('thankyou')
  end

  def last_page_is_certificate?
    find_module_by_name.content.last.page_type.eql?('certificate')
  end

  def has_ten_summative_questions?
    find_module_by_name.page_by_type('summative_questionnaire').count.eql? 10
  end

  # ------------------- Also to add? ---------------------

  # demo content tallies are met (this shouldn’t be necessary for genuine content)
  # count how many things we're expecting - in the data sanity check

  # depends on values are present for modules 2-10
  # order of the modules

  # pages have a parent value

  # training_module needs to have a thumbnail
  # should be validated on the contentful model

  # configurable to check both APIs?

  # does every question have a json object on it that looks right
  # JSON checker could be a different class
end
