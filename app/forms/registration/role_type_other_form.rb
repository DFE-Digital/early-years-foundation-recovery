module Registration
  class RoleTypeOtherForm < BaseForm
    attr_accessor :role_type_other

    validates :role_type_other, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(role_type: 'other', role_type_other: role_type_other)
    end
  end
end
