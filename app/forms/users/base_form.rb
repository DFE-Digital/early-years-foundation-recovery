module Users
  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    def self.model_name
      ActiveModel::Name.new(self, nil, "User")
    end

    attr_accessor :user

    def save
      raise "Define in child class"
    end
  end
end
