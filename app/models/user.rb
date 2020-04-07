class User < ApplicationRecord
  class EmailTaken < StandardError;end

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
  validate :user_name_allowed?
  # 30 for Instagram, 15 for Twitter
  validates_length_of :user_name, maximum: 30
  # check some more of this out later
  # https://hackernoon.com/performing-custom-validations-in-rails-an-example-9a373e807144

  after_validation :check_for_email_taken

  private

  # make emails case insensitive
  def downcase_email
    self.email = email.downcase
  end

  def remove_empty_spaces
    self.email = email.strip
    self.name = name.strip
    self.user_name = user_name.strip
  end

  # periods and spaces allowed based off twitter and instagram
  def user_name_allowed?
    return if user_name.match /\A[a-zA-Z0-9._]+\z/

    errors.add(:user_name, 'Usernames can only use letters, numbers, underscores and periods.')
    false
  end

  # https://spilth.org/blog/2017/08/31/preventing-email-address-leaking-with-devise/
  def check_for_email_taken
    return unless errors.details.key?(:email)

    raise EmailTaken if only_email_errors? && only_email_taken_errors?

    scrub_email_taken_errors
  end

  def only_email_errors?
    errors.details.keys == [:email]
  end

  def only_email_taken_errors?
    errors.details[:email].collect { |detail| detail[:error] }.uniq == [:taken]
  end

  def scrub_email_taken_errors
    errors.details[:email].reject! {|detail| detail[:error] == :taken}
    errors.details.delete(:email) if errors.details[:email].empty?

    errors.messages[:email].reject! {|message| message == 'has already been taken'}
    errors.messages.delete(:email) if errors.messages[:email].empty?
  end

end
