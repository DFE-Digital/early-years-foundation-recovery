module DateHelper
  def certificate_date(datetime)
    datetime.to_date.strftime('%-d %B %Y')
  end
end
