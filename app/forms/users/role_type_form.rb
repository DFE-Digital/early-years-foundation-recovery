module Users
  class RoleTypeForm < BaseForm
    attr_accessor :role_type

    validates :role_type, presence: true

    # @return [String]
    def name
      'role_types'
    end

    # @return [Array<Trainee::Role>]
    def role_types
      if user.childminder?
        Trainee::Role.by_group('childminder')
      else
        Trainee::Role.by_group('other')
      end
    end

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(role_type: role_type, role_type_other: nil)
    end
  end
end
