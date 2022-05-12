class OfstedValidator < ActiveModel::Validator
  def validate(record)
    ofsted_reports = 'https://reports.ofsted.gov.uk/childcare/search?q='
    ofsted_uri = URI(ofsted_reports + record.ofsted_number.to_s)
    result = Net::HTTP.get(ofsted_uri)

    unless result.include?("URN: <strong>#{record.ofsted_number}</strong>")
      record.errors.add :ofsted_number, 'This OFSTED number is not recognised'
    end
  end
end
