require 'rails_helper'

RSpec.describe 'Registrations', type: :feature do

  let(:required_params) { ['name', 'user_name', 'email', 'password']}
  let(:existing_user) { create(:user) }
  let(:user_name_invalid_error_message) { 'Usernames can only use letters, numbers, underscores and periods.' }
  let(:user_confirm_instructions) { 'You will receive an email with instructions about how to confirm your account in a few minutes.' }

  context 'sign up page' do

    before(:each) do
      visit new_user_registration_path
      expect_success new_user_registration_path
    end

    context 'sign up fails' do

      context 'invalid params' do
        it 'skipped params' do
          required_params.map do |skip_param|
            fill_sign_up_form skip_param
            expect_sign_up_fails
            visit new_user_registration_path
          end
        end

        context 'attribute' do

          before(:each) do
            fill_sign_up_form
          end

          after(:each) do
            expect_sign_up_fails
          end

          context 'password' do
            it 'too short' do
              fill_in 'Password', with: 'passwo'
            end

            it 'too long' do
              fill_in 'Password', with: 'p' * 129 # max 128 chars
            end
          end

          context 'user_name' do
            it 'special character' do
              fill_in 'Username', with: 'user1234!'
              expect_sign_up_fails
              expect(page).to have_content user_name_invalid_error_message
            end

            it 'hyphen' do
              fill_in 'Username', with: 'user-1234'
              expect_sign_up_fails
              expect(page).to have_content user_name_invalid_error_message
            end

            it 'space' do
              fill_in 'Username', with: 'user 1234'
              expect_sign_up_fails
              expect(page).to have_content user_name_invalid_error_message
            end

            it 'too long' do
              # 30 for Instagram, 15 for Twitter
              fill_in 'Username', with: 'a' * 31 # => 31 chars
              expect_sign_up_fails
              expect(page).to have_content 'User name is too long (maximum is 30 characters)'
            end
          end
        end
      end

      context 'non-unique user attributes' do
        it 'matching user_name' do
          fill_sign_up_form
          fill_in 'Username', with: existing_user.user_name
          expect_sign_up_fails
          expect(page).to have_content 'User name has already been taken'
          expect(page).to have_content 'User name has already been taken'
        end

        it 'matching email' do
          fill_sign_up_form
          fill_in 'Email', with: existing_user.email
          expect_sign_up_fails
          expect_confirm_path
        end
      end
    end

    context 'sign up succeeds' do

      before(:each) do
        fill_sign_up_form
      end

      after(:each) do
        expect_sign_up_succeeds
        user = User.last
        expect(user.confirmed?).to be_falsey
        expect_confirm_path

        expect(user.name).to eq user.name.strip
        expect(user.user_name).to eq user.user_name.strip
        expect(user.email).to eq user.email.strip
      end

      it 'with standard input' do
      end

      context 'user_name' do
        it 'letters and numbers' do
          fill_in 'Username', with: "#{Faker::Hipster.word}123"
        end

        it 'underscore' do
          fill_in 'Username', with: "#{Faker::Hipster.word}_123"
        end

        it 'period' do
          fill_in 'Username', with: "#{Faker::Hipster.word}.123"
        end

        it 'min length' do
          fill_in 'Username', with: 'a'
        end

        it 'max length' do
          # 30 for Instagram, 15 for Twitter
          fill_in 'Username', with: 'a' * 30
        end
      end

      context 'password' do
        it 'has special characters' do
          fill_in 'Password', with: 'password!@#/+=_s'
        end

        it 'has space' do
          fill_in 'Password', with: 'pass word'
        end
      end

      it 'with extra spaces' do
        fill_in 'Name', with: "#{Faker::Name.name} "
        fill_in 'Username', with: "#{Faker::Hipster.word} "
        fill_in 'Email', with: "#{Faker::Internet.email} "
        fill_in 'Password', with: 'password!'
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

  def expect_sign_up_succeeds
    expect do
      click_button 'Sign up'
    end.to change(User, :count).by(1)
  end

  def expect_confirm_path
    expect(current_path).to eq confirm_path
    expect(page).to have_content user_confirm_instructions
  end
end
