module RedirectSpecHelper

  def expect_require_login
    expect_redirect
    expect(response).to redirect_to(new_user_session_path)
  end

  def expect_redirect
    expect(response).to_not be_successful
    expect(response).to have_http_status(:redirect)
    expect(response).to be_redirect
  end

  def expect_success
    expect(response).to be_successful
    expect(response).to have_http_status(:ok)
    expect(response).to_not be_redirect
  end

end
