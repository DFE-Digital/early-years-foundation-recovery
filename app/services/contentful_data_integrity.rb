# return a boolean to tell us whether the training modules in Contentful all have the
# correct characterisitics

class ContentfulDataIntegrity
  extend Dry::Initializer

  option :environment, required: true
  option :training_module, required: true
  option :cached, required: true

  def valid?
    mod = find_module_by_name(training_module)
    return false if find_module_by_name(training_module).nil?
    
    if has_video_page 
      && first_page_is_interruption 
      && last_page_is_certificate
      return true
    end

    false
  end

private

  def find_module_by_name(name)
    fetch_or_store(name) do
      Training::Module.by_name(name)
    end
  end

  # # 1, 3, 1, 2 would fail
  # # 1, 3, 4 would fail
  # # should increase by one each time
  # submodules and topics increment
  def topics_in_order
    mod.content_by_submodule_topic.keys
  end

  def submodules_in_order
    mod.content_by_submodule.keys
  end

  # # e.g. each module needs video page
  # one of each required page type is present
  def has_video_page
    mod.content.any?(Training::Video)
  end
    

  # first page needs to be interruption
  def first_page_is_interruption
    mod.content.first.page_type.eql? 'interruption_page'
  end
  
  # last page needs to be certificate
  def last_page_is_certificate
    mod.content.last.page_type.eql? 'certificate'
  end
  
  # should be 10 summative questionnaire types
  def has_ten_summative_questions
    mod.page_by_type('summative_questionnaire').count.eql? 10
  end
  
  # types appear in the correct order
  def modules_are_ordered_correctly
    arr = mod.content.drop(1).map {|m| m.name}
    arr == arr.sort
  end


  # depends on values are present for modules 2-10
  # order of the modules

  # pages have a parent value

  # demo content tallies are met (this shouldn’t be necessary for genuine content)
  # count how many things we're expecting - in the data sanity check

  # training_module needs to have a thumbnail
  # should be validated on the contentful model

  # configurable to check both APIs?

  # does every question have a json object on it that looks right
  # JSON checker could be a different class
end