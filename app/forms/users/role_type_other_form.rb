module Users
  class RoleTypeOtherForm < BaseForm
    attr_accessor :role_type_other

    validates :role_type_other, presence: true

    def name
      'role_type_others'
    end

    def save
      if valid?
        user.update!(
          role_type: 'other',
          role_type_other: role_type_other,
        )
      end
    end
  end
end
