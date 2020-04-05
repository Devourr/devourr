require 'rails_helper'

RSpec.describe 'Registrations', type: :feature do

  let(:required_params) { ['name', 'user_name', 'email', 'password']}
  let(:existing_user) { create(:user) }

  context 'sign up page' do

    context 'sign up fails' do

      before(:each) do
        visit new_user_registration_path
        expect_success new_user_registration_path
      end

      it 'invalid params' do
        required_params.map do |param|
          fill_sign_up_form(param)
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
end
