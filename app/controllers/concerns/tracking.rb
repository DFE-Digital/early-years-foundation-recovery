# Create and query Ahoy::Events
#
module Tracking
  extend ActiveSupport::Concern

private

  # Record user event
  #
  # @param key [String]
  # @param data [Hash]
  #
  # @return [Boolean]
  def track(key, **data)
    properties = {
      path: request.fullpath,     # user perspective
      **request.path_parameters,  # developer perspective
      **data,
    }
    ahoy.track(key, properties)
  end

  # Check if a specific user event has already been logged
  #
  # @param key [String]
  # @param params [Hash]
  #
  # @return [Boolean]
  def untracked?(key, **params)
    Ahoy::Event.where(user_id: current_user, name: key).where_properties(**params).empty?
  end
  
  def track_events
    track('module_content_page')

    if track_module_start?
      track('module_start')
      helpers.calculate_module_state
    end

    if module_item.assessment_results? && module_complete_untracked?
      track('module_complete')
      helpers.calculate_module_state
    end

    track('confidence_check_complete') if track_confidence_check_complete?
  end

  # @return [Boolean]
  def track_module_start?
    module_item.module_intro? && untracked?('module_start', training_module_id: training_module_name)
  end

  # @return [Boolean]
  def track_confidence_check_complete?
    helpers.module_progress(module_item.parent).completed? && untracked?('confidence_check_complete', training_module_id: training_module_name)
  end

  def module_complete_untracked?
    return false if untracked?('module_start', training_module_id: training_module.name)

    untracked?('module_complete', training_module_id: training_module.name)
  end
end
