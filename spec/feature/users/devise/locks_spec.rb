require 'rails_helper'

RSpec.describe 'Locks', type: :feature do

  let(:user) { create(:user, :confirmed) }

  context 'locks a user' do
    it 'after 5 invalid attempts' do
      3.times do
        attempt_sign_in(user.email, 'wrongpasswordz')
        expect(current_path).to_not eq(root_path)
        expect(page).to have_content 'Invalid Email or password.'
      end

      # warning
      attempt_sign_in(user.email, 'wrongpasswordz')
      expect(current_path).to_not eq(root_path)
      expect(page).to have_content 'You have one more attempt before your account is locked.'

      # locked
      attempt_sign_in(user.email, 'wrongpassword')
      expect(current_path).to_not eq(root_path)
      expect(page).to have_content 'Your account is locked.'

      # can't sign in
      attempt_sign_in # => with correct credentials
      expect(current_path).to_not eq(root_path)
      expect(page).to have_content 'Your account is locked.'
    end

  end
end
