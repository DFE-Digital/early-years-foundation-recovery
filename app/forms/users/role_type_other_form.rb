module Users
  class RoleTypeOtherForm < BaseForm
    attr_accessor :role_type_other

    validates :role_type_other, presence: true

    # @return [String]
    def name
      'role_type_others'
    end

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(role_type: 'other', role_type_other: role_type_other)
    end
  end
end
