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
        expect(current_path).to_not eq(root_path)
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
    end

    context 'can sign in' do
      it 'confirmed user' do
        user.confirm
        attempt_sign_in
        expect(current_path).to eq(root_path)
      end
    end
  end
end
