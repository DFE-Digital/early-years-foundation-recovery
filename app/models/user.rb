class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable, :recoverable and :omniauthable
  # TODO: Add :confirmable when emails set up
  devise :database_authenticatable, :registerable,
         :validatable, :rememberable
end
