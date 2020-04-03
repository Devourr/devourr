class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name

  before_save :downcase_email

  # make emails case insensitive
  def downcase_email
    self.email = email.downcase
  end
end
