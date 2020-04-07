class ApplicationController < ActionController::Base
  include DeviseSetup
  include MailerHost
  include EmailSecurity

end
