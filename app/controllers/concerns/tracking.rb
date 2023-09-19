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
      **tracking_properties,
      **data,
    }
    ahoy.track(key, properties)
  end

  # @return [Hash]
  def tracking_properties
    {}
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
end
