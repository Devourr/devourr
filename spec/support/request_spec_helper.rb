module RequestSpecHelper
  # https://github.com/heartcombo/devise/wiki/How-To:-sign-in-and-out-a-user-in-Request-type-specs-(specs-tagged-with-type:-:request)
  include Warden::Test::Helpers

  def self.included(base)
    base.before(:each) { Warden.test_mode! }
    base.after(:each) { Warden.test_reset! }
  end

  def sign_in(resource)
    login_as(resource, scope: warden_scope(resource))
  end

  def sign_out(resource)
    logout(warden_scope(resource))
  end

  def attempt_sign_in(login = user.email, password = user.password)
    visit new_user_session_path
    expect_success new_user_session_path

    fill_in 'Login', with: login
    fill_in 'Password', with: password
    click_button 'Log in'
  end

  private

  def warden_scope(resource)
    resource.class.name.underscore.to_sym
  end
end
