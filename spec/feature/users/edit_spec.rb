require 'rails_helper'

# this could be done from the devise/registration_spec,
# but opting for separate file
RSpec.describe 'User edit', type: :feature do

  let(:user) { create(:user, :confirmed) }

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

    it 'user content' do
      within '#content' do
        expect(page).to have_content("Edit #{user.name}")
      end
    end

    context 'update fails' do
      it 'missing attributes' do
        within '#header' do
          expect(page).to have_link('Edit password', href: "/#{user.user_name}/account/edit")
        end
      end
    end

    context 'update succeeds' do

    end
  end
end
