require 'rails_helper'

# this could be done from the devise/registration_spec,
# but opting for separate file
RSpec.describe 'User edit', type: :feature do

  let(:user) { create(:user, :confirmed) }

  before(:each) do
    sign_in user
    binding.pry
    visit edit_profile_path(user.user_name)
  end

  context 'non-existing user' do
    it 'redirects to root path' do
      visit edit_profile_path('nobody')
      expect_root_path
    end
  end

  context 'existing user' do

    it 'redirects if requested by id' do
      visit "/#{user.id}"
      expect_root_path
    end

    it 'user content' do
      within '#content' do
        expect(page).to have_content(user.name)
      end
    end

    context 'user is me' do
      it 'shows edit profile link' do
        within '#header' do
          expect(page).to have_link('Edit profile', href: "/#{user.user_name}/edit")
        end
      end
    end
  end
end
