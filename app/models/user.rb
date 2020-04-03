class User < ApplicationRecord
  # uuid primary key would break `.first` and `.last` methods
  # https://github.com/rails/rails/pull/34480
  self.implicit_order_column = 'created_at'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :name
  validates_presence_of :user_name
  validates_uniqueness_of :user_name

  before_save :downcase_email

  # make emails case insensitive
  def downcase_email
    self.email = email.downcase
  end
end
