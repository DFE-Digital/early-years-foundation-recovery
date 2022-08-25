class CertificatePage < OpenStruct
  include ActiveModel::Model

  attr_accessor :id, :name, :type, :training_module

  def heading
    name
  end
end