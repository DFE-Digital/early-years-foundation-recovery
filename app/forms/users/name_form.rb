module Users
  class NameForm < BaseForm
    attr_accessor :first_name, :last_name

    validates :first_name, :last_name, presence: true

    def save
      user.update(first_name: first_name, last_name: last_name) if valid?
    end
  end
end
