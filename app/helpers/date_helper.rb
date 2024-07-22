module DateHelper
  # @return [String]
  def format_date(datetime)
    datetime.to_date.strftime('%-d %B %Y')
  end
end
