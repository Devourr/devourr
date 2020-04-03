module DeviseSetup
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :authenticate_user!
  end

  # no password_confirmation -- if params exclude it then it will not be required
  # https://github.com/heartcombo/devise/wiki/Disable-password-confirmation-during-registration
  # https://uxmovement.com/forms/why-the-confirm-password-field-must-die/
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user|
      user.permit(:name, :user_name, :email, :password)
    end
    devise_parameter_sanitizer.permit(:sign_in) do |user|
      user.permit(:password, :remember_me)
    end
    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit(:name, :user_name, :email, :current_password, :password)
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || signed_in_root_path(resource_or_scope)
  end

end
