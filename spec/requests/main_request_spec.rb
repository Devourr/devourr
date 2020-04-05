require 'rails_helper'

RSpec.describe "Mains", type: :request do
  # https://www.rubydoc.info/gems/rspec-rails/RSpec%2FRails%2FMatchers:have_http_status

  let(:user) { create(:user, :confirmed) }

  it 'does not allow access to main page if not logged in' do
    get root_path
    expect(response).to have_http_status(:redirect)
  end

  it 'allows access to main page if logged in' do
    sign_in user
    get root_path
    expect(response).to have_http_status(:ok)
  end
end
