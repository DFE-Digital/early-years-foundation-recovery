module Users
  class RoleTypeForm < BaseForm
    attr_accessor :role_type

    validates :role_type, presence: true

    def name
      'role_types'
    end

    def role_types
      if user.childminder?
        RoleType.where(group: :childminder)
      else
        RoleType.where(group: :other)
      end
    end

    def save
      if valid?
        user.update!(
          role_type: role_type,
        )
      end
    end
  end
end
