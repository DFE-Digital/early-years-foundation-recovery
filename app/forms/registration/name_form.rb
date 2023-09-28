module Registration
  class NameForm < BaseForm
    attr_accessor :first_name, :last_name

    validates :first_name, :last_name, presence: true

    # @return [Boolean]
    def save
      return false unless valid?

      user.update!(first_name: first_name, last_name: last_name)
    end
  end
end
