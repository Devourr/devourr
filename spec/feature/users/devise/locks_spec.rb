require 'rails_helper'

RSpec.describe 'Locks', type: :feature do

  let(:user) { create(:user, :confirmed) }

  context 'locks a user' do
    it 'after 5 invalid attempts' do
      3.times do
        attempt_sign_in(user.email, 'wrongpasswordz')
        expect(current_path).to_not eq(root_path)
        expect(page).to have_content 'Invalid Email or password.'
      end

      # warning
      attempt_sign_in(user.email, 'wrongpasswordz')
      expect(current_path).to_not eq(root_path)
      expect(page).to have_content 'You have one more attempt before your account is locked.'

      # locked
      attempt_sign_in(user.email, 'wrongpassword')
      expect(current_path).to_not eq(root_path)
      expect(page).to have_content 'Your account is locked.'

      # can't sign in
      attempt_sign_in # => with correct credentials
      expect(current_path).to_not eq(root_path)
      expect(page).to have_content 'Your account is locked.'
    end
  end

  context 'unlock fails' do

    before(:each) do
      user.lock_access!
    end

    it 'no token' do
      expect(user.unlock_token).to be_present
      visit user_unlock_path
      expect_access_locked
      expect(current_path).to_not eq new_user_session_path
      expect(page).to have_content 'Unlock token can\'t be blank'
    end

    it 'invalid token' do
      visit user_unlock_path({ unlock_token: 'invalid_token' })
      expect_access_locked
      expect(current_path).to_not eq new_user_session_path
      expect(page).to have_content 'Unlock token is invalid'
    end

    it 'already unlocked' do
      raw_token = user.lock_access!
      user.unlock_access!
      expect_access_unlocked

      visit user_unlock_path({ unlock_token: raw_token })
      expect(current_path).to_not eq new_user_session_path
      expect(page).to have_content 'Unlock token is invalid'
    end

    it 'not enough time has passed' do
      travel_to Time.now + 14.minutes

      visit new_user_session_path
      expect_login_fails
      expect(page).to have_content 'Your account is locked.'

      travel_back
    end
  end

  context 'unlock succeeds' do

    it 'with token' do
      # https://github.com/heartcombo/devise/blob/master/test/integration/lockable_test.rb#L85
      raw_token = user.lock_access!

      visit user_unlock_path({ unlock_token: raw_token })
      expect_access_unlocked
      expect(current_path).to eq new_user_session_path
      expect(page).to have_content 'Your account has been unlocked successfully. Please sign in to continue.'

      attempt_sign_in
      expect(current_path).to eq root_path
    end

    it 'after time' do
      user.lock_access!
      expect_access_locked

      travel_to Time.now + 16.minutes

      visit new_user_session_path
      expect_login_success

      travel_back
    end
  end

  def expect_access_locked
    expect(user.reload.access_locked?).to be_truthy
  end

  def expect_access_unlocked
    expect(user.reload.access_locked?).to be_falsey
  end

  def expect_login_fails
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect(current_path).to_not eq(root_path)
  end

  def expect_login_success
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect(current_path).to eq(root_path)
  end
end
