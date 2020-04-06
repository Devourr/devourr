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
  # periods and spaces allowed based off twitter and instagram
  validates :user_name, format: { with: /\A[a-zA-Z0-9._]+\z/,
                                  message: :format_error_message }
  # 30 for Instagram, 15 for Twitter
  validates_length_of :user_name, maximum: 30
  # check some more of this out later
  # https://hackernoon.com/performing-custom-validations-in-rails-an-example-9a373e807144

  # make emails case insensitive
  def downcase_email
    self.email = email.downcase
  end

  def remove_empty_spaces
    self.email = email.strip
    self.name = name.strip
    self.user_name = user_name.strip
  end

  # username still failing in some factorybots
  def format_error_message
    binding.pry
    'Usernames can only use letters, numbers, underscores and periods.'
  end

end
