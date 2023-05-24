# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Household Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting households' do
    describe 'Getting list of households' do
      before do
        @account_data = DATA[:accounts][0]
        account = OnlineCheckIn::Account.create(@account_data)
        account.add_owned_household(DATA[:households][0])
        account.add_owned_household(DATA[:households][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = OnlineCheckIn::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/households'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/households'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single household' do
      existing_house = DATA[:households][1]
      OnlineCheckIn::Household.create(existing_house)
      id = OnlineCheckIn::Household.first.id

      get "/api/v1/households/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['houseowner']).must_equal existing_house['houseowner']
    end

    it 'SAD: should return error if unknown household requested' do
      get '/api/v1/households/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      OnlineCheckIn::Household.create(houseowner: 'New Household')
      OnlineCheckIn::Household.create(houseowner: 'Newer Household')
      get 'api/v1/households/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Households' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @house_data = DATA[:households][1]
    end

    it 'HAPPY: should be able to create new households' do
      post 'api/v1/households', @house_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      house = OnlineCheckIn::Household.first

      _(created['id']).must_equal house.id
      _(created['houseowner']).must_equal @house_data['houseowner']
      _(created['floorNo']).must_equal @house_data['floorNo']
      _(created['contact']).must_equal @house_data['contact']
    end

    it 'SECURITY: should not create households with mass assignment' do
      bad_data = @house_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/households/', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
