module User::ProfileHelper
  def on_profile?
    request.path == profile_path(current_user.user_name) if current_user
  end

  def on_edit_profile?
    request.path == edit_profile_path(current_user.user_name) if current_user
  end
end
