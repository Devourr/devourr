require 'rails_helper'

RSpec.describe 'Confirmations', type: :feature do

  let(:user) { create(:user) }

  context 'confirmation link' do

    before(:each) do
      visit user_confirmation_path
      expect_success user_confirmation_path
    end

    context 'confirmation fails' do

      it 'no token' do
        expect(user.confirmation_token).to be_present
        visit user_confirmation_path
        expect_confirmation_fails
        expect(current_path).to_not eq new_user_session_path
        expect(page).to have_content 'Confirmation token can\'t be blank'
      end

      it 'invalid token' do
        visit user_confirmation_path({ confirmation_token: 'invalid_token' })
        expect_confirmation_fails
        expect(current_path).to_not eq new_user_session_path
        expect(page).to have_content 'Confirmation token is invalid'
      end

      it 'already confirmed' do
        user.confirm
        expect_confirmation_succeeds
        visit user_confirmation_path({ confirmation_token: user.confirmation_token })
        expect(current_path).to_not eq new_user_session_path
        # curious if this is a security concern, can check if email taken from sign_up
        expect(page).to have_content 'Email was already confirmed, please try signing in'
      end
    end

    context 'confirmation succeeds' do
      it 'with confirmation token' do
        expect(user.confirmation_token).to be_present
        visit user_confirmation_path({ confirmation_token: user.confirmation_token })
        expect_confirmation_succeeds
        expect(current_path).to eq new_user_session_path
        expect_login_success
      end

      # "Confirmable will not generate a new token if a repeat confirmation is requested
      # during this time frame, unless the user's email changed too."
      # I'm ok with this -- less confusing sign_up the better
      # https://www.rubydoc.info/github/plataformatec/devise/Devise/Models/Confirmable
      it 'after re-requesting confirmation token (token stays the same)' do
        original_confirmation_token = user.confirmation_token

        visit new_user_confirmation_path
        fill_in 'Email', with: user.email
        click_button 'Resend confirmation instructions'
        expect(user.reload.confirmation_token).to eq original_confirmation_token

        visit user_confirmation_path({ confirmation_token: original_confirmation_token })
        expect_confirmation_succeeds
        expect(current_path).to eq new_user_session_path
        expect_login_success
      end
    end
  end

  def expect_confirmation_fails
    expect(user.reload.confirmed?).to be_falsey
  end

  def expect_login_fails
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect_not_root_path
  end

  def expect_confirmation_succeeds
    expect(user.reload.confirmed?).to be_truthy
  end

  def expect_login_success
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect_root_path
  end
end
