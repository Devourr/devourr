require 'rails_helper'

RSpec.describe "Mains", type: :request do

  it 'allows access to main page' do
    get '/'
    expect(response).to have_http_status(:ok)
  end
end
