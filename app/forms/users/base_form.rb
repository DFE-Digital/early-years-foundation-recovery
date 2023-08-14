module Users
  class BaseForm
    include ActiveModel::Model
    include ActiveModel::Validations

    # @return [?]
    def self.model_name
      ActiveModel::Name.new(self, nil, 'User')
    end

    # Move?
    # -------------------
    attr_accessor :user, :setting_type_id

    # @return [Trainee::Setting, OpenStruct]
    def setting_type
      Trainee::Setting.by_name(setting_type_id)
    end
    # -------------------

    # @return [String]
    def heading
      I18n.translate('heading', scope: i18n_scope)
    end

    # @return [String]
    def body
      I18n.translate('body', scope: i18n_scope)
    end

    # @return [String]
    def button
      I18n.translate('button', scope: i18n_scope)
    end

    # @return [Array<String>]
    def i18n_scope
      ['registration', name, 'edit']
    end

    def parent
      OpenStruct.new(title: nil)
    end

    # TODO: form error class
    #
    # @raise [?]
    def save
      raise 'Define in child class'
    end
  end
end
