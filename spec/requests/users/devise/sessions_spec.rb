require 'rails_helper'

RSpec.describe 'Sessions' do

  # controller.current_user fails when nil
  # controller.try(:current_user) as fallback
  it 'signs user in and out' do
    user = create(:user)
    user.confirm

    sign_in user
    get root_path
    expect(controller.try(:current_user)).to eq(user)

    sign_out user
    get root_path
    expect(controller.try(:current_user)).to be_nil
  end
end
