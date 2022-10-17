module Users
  class RoleTypeForm < BaseForm
    attr_accessor :role_type

    validates :role_type, presence: true

    def save
      if valid?
        user.update!(
          role_type: role_type,
        )
      end
    end
  end
end
