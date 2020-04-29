class ApplicationController < ActionController::Base
  include DeviseSetup
  include MailerHost
  include EmailSecurity

  # creates an array of message hashes (if one does not already exist)
  # and allows messages to be added to it
  # https://onehundredairports.com/2017/04/05/creating-multiple-flash-messages-in-ruby-on-rails/
  def add_message(type, text)
    @messages ||= []
    @messages.push({type: type, text: text})
  end

end
