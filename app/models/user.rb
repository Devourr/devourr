class User < ApplicationRecord
  # uuid primary key would break `.first` and `.last` methods
  # https://github.com/rails/rails/pull/34480
  self.implicit_order_column = 'created_at'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  before_validation :downcase_email
  before_validation :remove_empty_spaces

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :name
  validates_presence_of :user_name
  validates_uniqueness_of :user_name
  validates :user_name, format: { with: /\A[a-zA-Z0-9]+\z/, message: 'Username must only contain letters and numbers' }

  # make emails case insensitive
  def downcase_email
    self.email = email.downcase
  end

  def remove_empty_spaces
    self.email = email.strip
    self.name = name.strip
    self.user_name = user_name.strip
  end
end
