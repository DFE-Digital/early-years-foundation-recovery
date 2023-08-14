module Registration
  class BaseForm < ApplicationForm
    # @return [ActiveModel::Name]
    def self.model_name
      ActiveModel::Name.new(self, nil, 'User')
    end

    attr_accessor :user, :setting_type_id

    # @return [Trainee::Setting, OpenStruct]
    def setting_type
      Trainee::Setting.by_name(setting_type_id)
    end
  end
end
