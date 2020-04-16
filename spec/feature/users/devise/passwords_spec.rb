require 'rails_helper'

RSpec.describe 'Passwords', type: :feature do

  let(:user) { create(:user, :confirmed) }
  let(:password_reset_instructions) { 'If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.' }

  # from profile
  context 'edit password' do

    before(:each) do
      sign_in user
    end

    context 'fails' do

    end

    context 'succeeds' do

    end
  end

  context 'request password reset' do

    it 'non-existing user' do
      visit password_reset_path
      expect_success password_reset_path
      submit_password_reset('fake@email.com')

      # don't show if email is invalid
      expect(page).to_not have_content 'Email not found'
      expect(page).to have_content password_reset_instructions
    end

    context 'cannot access password reset' do

      it 'no token' do
        visit edit_user_password_path
        expect_not_root_path
      end

      context 'signed in user' do

        before(:each) do
          sign_in user
        end

        it 'request password reset' do
          visit password_reset_path
          expect_root_path
        end

        it 'edit password' do
          visit edit_user_password_path
          expect_root_path
        end
      end
    end

    it 'can access without resetting password' do
      visit password_reset_path
      expect_success password_reset_path
      submit_password_reset
      visit new_user_session_path
      expect_login_success
    end

    context 'existing user' do

      before(:each) do
        visit password_reset_path
        expect_success password_reset_path
      end

      after(:each) do
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content password_reset_instructions

        # testing only hack to generate a raw token
        raw_token = user.send(:set_reset_password_token)

        visit edit_user_password_path(reset_password_token: raw_token)
        fill_in 'New password', with: 'password'
        click_button 'Change my password'

        expect_root_path
        expect(page).to have_content 'Your password has been changed successfully. You are now signed in.'
      end

      it 'forgotton' do
        submit_password_reset
      end

      it 'locked' do
        user.lock_access!
        submit_password_reset
      end

      it 'case-insensitive email' do
        fill_in 'Email', with: user.email.upcase
        click_button 'Send me reset password instructions'
      end

      it 'email with trailing space' do
        fill_in 'Email', with: "#{user.email} "
        click_button 'Send me reset password instructions'
      end
    end
  end

  def submit_password_reset(email = user.email)
    fill_in 'Email', with: email
    click_button 'Send me reset password instructions'
  end

  def expect_login_success
    fill_in 'Login', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect(current_path).to eq(root_path)
  end
end
