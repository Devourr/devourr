module RedirectSpecHelper

  def expect_require_login
    expect(current_path).to eq new_user_session_path
  end

  def expect_success(request_path)
    expect(current_path).to eq request_path
  end

  def expect_root_path
    expect(current_path).to eq root_path
  end

  def expect_not_root_path
    expect(current_path).to_not eq root_path
  end

  def expect_profile_path
    expect(current_path).to eq profile_path(user.user_name)
  end

  def expect_not_profile_path
    expect(current_path).to_not eq profile_path(user.user_name)
  end

end
