# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToHousehold service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      OnlineCheckIn::Account.create(account_data)
    end
  end

  it 'HAPPY: should authenticate valid account credentials' do
    credentials = DATA[:accounts].first
    account = OnlineCheckIn::AuthenticateAccount.call(
      username: credentials['username'], password: credentials['password']
    )
    _(account).wont_be_nil
  end

  it 'SAD: will not authenticate with invalid password' do
    credentials = DATA[:accounts].first
    _(proc {
      OnlineCheckIn::AuthenticateAccount.call(
        username: credentials['username'], password: 'malword'
      )
    }).must_raise OnlineCheckIn::AuthenticateAccount::UnauthorizedError
  end

  it 'BAD: will not authenticate with invalid credentials' do
    _(proc {
      OnlineCheckIn::AuthenticateAccount.call(
        username: 'maluser', password: 'malword'
      )
    }).must_raise OnlineCheckIn::AuthenticateAccount::UnauthorizedError
  end
end

# Send correct authorization header to test API resource requests
describe 'Getting households' do
  describe 'Getting list of households' do
    before do
      @account_data = DATA[:accounts][0]
      account = OnlineCheckIn::Account.create(@account_data)
      account.add_owned_project(DATA[:households][0])
      account.add_owned_project(DATA[:households][1])
    end
    # First get authenticated account + auth token
    it 'HAPPY: should get list for authorized account' do
      auth = OnlineCheckIn::AuthenticateAccount.call(
        username: @account_data['username'],
        password: @account_data['password']
      )
      # Pass auth token in authorization header of resource request
      header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
      get 'api/v1/households'
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end
    # sned bad auth token in authenticationheader
    it 'BAD: should not process for unauthorized account' do
      header 'AUTHORIZATION', 'Bearer bad_token'
      get 'api/v1/households'
      _(last_response.status).must_equal 403
      result = JSON.parse last_response.body
      _(result['data']).must_be_nil
    end
  end
end
