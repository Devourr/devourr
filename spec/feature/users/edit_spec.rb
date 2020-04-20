require 'rails_helper'

# this could be done from the devise/registration_spec,
# but opting for separate file
RSpec.describe 'User edit', type: :feature do

  let(:user) { create(:user, :confirmed) }
  let(:required_params) { ['name', 'user_name', 'email']}
  let(:user_name_invalid_error_message) { 'Usernames can only use letters, numbers, underscores and periods.' }

  before(:each) do
    sign_in user
    visit edit_profile_path(user.user_name)
  end

  context 'non-existing user' do
    it 'redirects to root path' do
      visit edit_profile_path('nobody')
      expect_root_path
      expect(page).to have_content 'Requested page is not available.'
    end
  end

  context 'existing user' do

    it 'redirects if requested by id' do
      visit "/#{user.id}/edit"
      expect_root_path
      expect(page).to have_content 'Requested page is not available.'
    end

    it 'has content' do
      within '#header' do
        expect(page).to have_link('Edit password', href: "/#{user.user_name}/account/edit")
      end

      within '#content' do
        expect(page).to have_content("Edit Profile")
      end
    end

    context 'update fails' do

      it 'missing attributes' do
        required_params.map do |skip_param|
          fill_edit_profile_form skip_param
          expect_update_profile_fails
          visit edit_profile_path(user.user_name)
          # todo: expect errors
        end
      end

      context 'invalid attributes' do

        context 'blank attributes' do
          it 'name' do
            fill_edit_profile_form 'name'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "Name can't be blank")
          end

          it 'user name' do
            fill_edit_profile_form 'user_name'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "User name can't be blank")
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'email' do
            fill_edit_profile_form 'email'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "Email can't be blank")
          end
        end

        context 'name' do
          it 'too long' do
            fill_in 'Name', with: 'a' * 71 # => 71 chars
            expect_update_profile_fails
            expect(page).to have_content 'Name is too long (maximum is 70 characters)'
          end
        end

        context 'user_name' do
          it 'not unique' do
            other_user = create(:user, :confirmed)
            fill_in 'Username', with: other_user.user_name
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "User name has already been taken")
          end

          it 'special character' do
            fill_in 'Username', with: 'user1234!'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'hyphen' do
            fill_in 'Username', with: 'user-1234'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'space' do
            fill_in 'Username', with: 'user 1234'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'too long' do
            # 30 for Instagram, 15 for Twitter
            fill_in 'Username', with: 'a' * 31 # => 31 chars
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: 'User name is too long (maximum is 30 characters)')
          end

          # prevent user names being taken that could belong to route paths
          # or reserved or offensive
          it 'blocked' do
            blocked_user_name = create(:blocked_user_name, user_name: 'admin')
            fill_in 'Username', with: blocked_user_name.user_name
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: 'Username is not available')
          end
        end

        context 'non-unique user attributes' do
          it 'matching user_name' do
            existing_user = create(:user, :confirmed)
            fill_edit_profile_form
            fill_in 'Username', with: existing_user.user_name
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: 'User name has already been taken')
          end

          it 'matching email' do
            existing_user = create(:user, :confirmed)
            fill_edit_profile_form
            fill_in 'Email', with: existing_user.email
            expect_update_profile_fails
          end
        end
      end
    end

    context 'update succeeds' do

    end
  end

  def fill_edit_profile_form(skip_param = nil)
    fill_in 'Name', with: skip_param == 'name' ? '' : 'My Name'
    fill_in 'Username', with: skip_param == 'user_name' ? '' : 'new_user_name'
    fill_in 'Email', with: skip_param == 'email' ? '' : 'new@email.com'
  end

  def expect_update_profile_fails
    click_button 'Update'
    expect(page).to have_content 'Edit Profile'
  end

  def expect_update_profile_succeeds
    click_button 'Update'
    expect_profile_path
  end
end
