class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable

  def name
    [first_name, last_name].compact.join(" ")
  end
end
