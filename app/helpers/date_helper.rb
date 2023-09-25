module DateHelper
  # @return [String]
  def certificate_date(datetime)
    datetime.to_date.strftime('%-d %B %Y')
  end
end
