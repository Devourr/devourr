require 'rails_helper'

RSpec.describe 'Sessions' do

  # controller.current_user fails when nil
  # controller.try(:current_user) as fallback

  let(:user) { create(:user) }
  let(:confirmed_user) { create(:user, :confirmed) }

  it 'does not sign in unconfirmed user' do
    sign_in user
    get root_path
    expect(controller.try(:current_user)).to be_nil
    expect_require_login
  end

  it 'signs confirmed user in and out' do
    sign_in confirmed_user
    get root_path
    expect(controller.try(:current_user)).to eq(confirmed_user)
    expect_success

    sign_out confirmed_user
    get root_path
    expect(controller.try(:current_user)).to be_nil
    expect_require_login
  end
end
