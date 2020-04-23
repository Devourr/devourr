module EmailSecurity
  extend ActiveSupport::Concern

  included do
    rescue_from User::EmailTakenCreate do |_exception|
      redirect_to confirm_path
      # redirect_to root_path, notice: t('devise.registrations.signed_up_but_unconfirmed')
    end

    rescue_from User::EmailTakenUpdate do |_exception|
      flash[:success] = user_update_message_success
      redirect_to profile_path(current_user.user_name)
    end
  end

  private

  def new_user_email
    params[:user][:email]
  end

  def user_update_message_success
    if current_user.email != new_user_email
      email_user_update_message_success_for_flash
    else
      'Profile was successfully updated.'
    end
  end

  # added link for typo/quick change https://ux.stackexchange.com/a/105809
  # https://stackoverflow.com/questions/2249431/put-a-link-in-a-flashnotice
  def email_user_update_message_success_for_flash
      %Q[ A confirmation email has been sent to <b>#{new_user_email}</b>. Click the link in the email to confirm the email address change #{view_context.link_to("Change this", edit_profile_path(@user.user_name))}.
    ].html_safe
  end

end
