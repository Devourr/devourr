module EmailSecurity
  extend ActiveSupport::Concern

  included do
    rescue_from User::EmailTaken do |_exception|
      redirect_to confirm_path
      # redirect_to root_path, notice: t('devise.registrations.signed_up_but_unconfirmed')
    end
  end

end
