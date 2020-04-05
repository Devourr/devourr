require 'rails_helper'

RSpec.describe 'Registrations', type: :feature do

  let(:required_params) { ['name', 'user_name', 'email', 'password']}
  let(:existing_user) { create(:user) }

  context 'sign up page' do

    before(:each) do
      visit new_user_registration_path
      expect_success new_user_registration_path
    end

    context 'sign up fails' do

      it 'invalid params' do
        required_params.map do |skip_param|
          fill_sign_up_form skip_param
          expect_sign_up_fails
          visit new_user_registration_path
        end
      end

      context 'non-unique user attributes' do
        it 'matching user_name' do
          fill_sign_up_form
          fill_in 'Username', with: existing_user.user_name
          expect_sign_up_fails
        end

        it 'matching email' do
          fill_sign_up_form
          fill_in 'Email', with: existing_user.email
          expect_sign_up_fails
        end
      end
    end

    it 'sign up succeeds' do
      fill_sign_up_form
      expect_sign_up_succeeds
      expect(User.last.confirmed?).to be_falsey
      expect(current_path).to eq confirm_path
      expect(page).to have_content "You will receive an email with instructions about how to confirm your account in a few minutes."
    end
  end

  def fill_sign_up_form(skip_param = nil)
    fill_in 'Name', with: Faker::Name.name unless skip_param == 'name'
    fill_in 'Username', with: Faker::Hipster.word unless skip_param == 'user_name'
    fill_in 'Email', with: Faker::Internet.email unless skip_param == 'email'
    fill_in 'Password', with: 'password' unless skip_param == 'password'
  end

  def expect_sign_up_fails
    expect do
      click_button 'Sign up'
    end.to change(User, :count).by(0)
  end

  def expect_sign_up_succeeds
    expect do
      click_button 'Sign up'
    end.to change(User, :count).by(1)
  end
end
