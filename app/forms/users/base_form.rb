module Users
  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :user, :setting_type_id

    def self.model_name
      ActiveModel::Name.new(self, nil, 'User')
    end

    def setting_type
      SettingType.find setting_type_id
    end
    delegate :local_authority_next?, :role_type_next?, to: :setting_type

    def model
      self
    end

    # @return [String]
    def heading
      I18n.translate('.heading', scope: i18n_scope)
    end

    # @return [String]
    def body
      I18n.translate('.body', scope: i18n_scope)
    end

    # @return [String]
    def button
      I18n.translate('.button', scope: i18n_scope)
    end

    # @return [Array<Symbol>]
    def i18n_scope
      [:registration, name, 'edit']
    end

    def parent
      OpenStruct.new(title: nil)
    end

    def save
      raise 'Define in child class'
    end
  end
end
