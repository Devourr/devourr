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

    it 'user content' do
      within '#content' do
        expect(page).to have_content(user.name)
      end
    end
  end
end
