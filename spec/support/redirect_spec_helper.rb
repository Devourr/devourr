module RedirectSpecHelper

  def expect_require_login
    expect(current_path).to eq new_user_session_path
  end

  def expect_success(request_path)
    expect(current_path).to eq request_path
  end

end
