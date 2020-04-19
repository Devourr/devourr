require 'rails_helper'

# this could be done from the devise/registration_spec,
# but opting for separate file
RSpec.describe 'User edit', type: :feature do

  let(:user) { create(:user, :confirmed) }
  let(:required_params) { ['name', 'user_name', 'email']}

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

      before(:each) do
        # visit edit_profile_path(user.user_name)
      end

      it 'missing attributes' do
        required_params.map do |skip_param|
          fill_edit_profile_form skip_param
          expect_update_profile_fails
          visit edit_profile_path(user.user_name)
          # todo: expect errors
        end
      end
    end

    context 'update succeeds' do

    end
  end

  def fill_edit_profile_form(skip_param = nil)
    fill_in 'Name', with: skip_param == 'name' ? '' : 'My Name'
    fill_in 'User name', with: skip_param == 'user_name' ? '' : 'new_user_name'
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
