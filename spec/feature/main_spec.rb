require 'rails_helper'

RSpec.describe 'Main content', type: :feature do

  let(:user) { create(:user, :confirmed) }

  before(:each) do
    sign_in user
    visit root_path
  end

  context 'has main content' do

    it 'has header links' do
      within '#header' do
        expect(page).to have_link('Sign out', href: '/signout')
        expect(page).to have_link('Profile', href: "/#{user.user_name}")
      end
    end
  end
end
