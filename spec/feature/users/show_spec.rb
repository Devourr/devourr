require 'rails_helper'

RSpec.describe 'User show', type: :feature do

  let(:user) { create(:user, :confirmed) }

  before(:each) do
    sign_in user
    visit profile_path(user.user_name)
  end

  context 'non-existing user' do
    it 'redirects to root path' do
      visit profile_path('nobody')
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
