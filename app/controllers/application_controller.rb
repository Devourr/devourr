class ApplicationController < ActionController::Base
  include DeviseSetup
  include MailerHost

end
