class User < ApplicationRecord
  class EmailTakenCreate < StandardError;end
  class EmailTakenUpdate < StandardError;end

  # uuid primary key would break `.first` and `.last` methods
  # https://github.com/rails/rails/pull/34480
  self.implicit_order_column = 'created_at'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable,
         authentication_keys: [:login]

  before_validation :downcase_email
  before_validation :remove_empty_spaces

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :name
  # https://ux.stackexchange.com/a/56165 # => what-is-a-good-name-length-limit
  validates_length_of :name, maximum: 70
  validates_presence_of :user_name
  validates_uniqueness_of :user_name, { case_sensitive: false }
  # 30 for Instagram, 15 for Twitter
  validates_length_of :user_name, maximum: 30
  validate :user_name_allowed?
  validate :user_name_available?
  # check some more of this out later
  # https://hackernoon.com/performing-custom-validations-in-rails-an-example-9a373e807144

  after_validation :check_for_email_taken

  # https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address#create-a-login-virtual-attribute-in-the-user-model
  attr_writer :login
  def login
    @login || self.user_name || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(user_name) = :value OR lower(email) = :value", { value: login.downcase.strip }]).first
    elsif conditions.has_key?(:user_name) || conditions.has_key?(:email)
      conditions[:email].downcase!.strip if conditions[:email]
      where(conditions.to_hash).first
    end
  end

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

  def user_name_available?
    return unless BlockedUserName.find_by_user_name(user_name)

    errors.add(:user_name, 'Username is not available')
    false
  end

  # https://spilth.org/blog/2017/08/31/preventing-email-address-leaking-with-devise/
  def check_for_email_taken
    return unless errors.details.key?(:email)

    # redirect to /confirm if email is taken from create profile
    # redirect to /user_name if email is taken from update profile
    if prevent_email_leak?
      raise persisted? ? EmailTakenUpdate : EmailTakenCreate
    end

    scrub_email_taken_errors
  end

  def prevent_email_leak?
    only_email_errors? && only_email_taken_errors?
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
