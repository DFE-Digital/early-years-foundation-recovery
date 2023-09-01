module Management

  # @return [Contentful::Management::Entry]
  def entry
    @entry ||= to_management
  rescue NoMethodError, Errno::ECONNREFUSED
    @entry = refetch_management_entry
  end

  # @return [nil, String]
  def published_at
    return unless Rails.env.development? && ENV['CONTENTFUL_MANAGEMENT_TOKEN'].present?

    entry.published_at&.in_time_zone(ENV['TZ'])&.strftime('%d-%m-%Y %H:%M')
  end

end
