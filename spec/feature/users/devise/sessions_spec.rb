require 'rails_helper'

RSpec.describe 'Sessions', type: :feature do

  let(:user) { create(:user) }
  let(:confirmed_user) { create(:user, :confirmed) }

  it 'does not sign in unconfirmed user' do
    sign_in user
    visit root_path
    expect_require_login
  end

  it 'signs confirmed user in and out' do
    sign_in confirmed_user
    visit root_path
    expect_success root_path

    sign_out confirmed_user
    visit root_path
    expect_require_login
  end

  context 'sign in page' do

    before(:each) do
      visit new_user_session_path
      expect_success new_user_session_path
    end

    context 'cannot sign in' do

      after(:each) do
        click_button 'Log in'
        expect_not_root_path
      end

      it 'wrong password' do
        fill_in 'Email', with: confirmed_user.email
        fill_in 'Password', with: 'wrongpassword'
      end

      it 'invalid params' do
        # fill_in 'Email', with: confirmed_user.email # test no email
        fill_in 'Password', with: confirmed_user.password
      end

      it 'unconfirmed user' do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
      end

      it 'locked user' do
        confirmed_user.lock_access!
        fill_in 'Email', with: confirmed_user.email
        fill_in 'Password', with: confirmed_user.password
      end
    end

    context 'can sign in' do

      before(:each) do
        user.confirm
      end

      it 'confirmed user' do
        attempt_sign_in
        expect_root_path
      end

      it 'and sign out' do
        expect(page).to_not have_content 'Sign out'
        attempt_sign_in
        expect_root_path
        expect(page).to have_content 'Sign out'
        click_link 'Sign out'
        expect_not_root_path
        expect(page).to have_content 'Signed out successfully.'
        visit root_path
        expect_not_root_path
      end
    end
  end
end
