# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Household Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = OnlineCheckIn::Account.create(@account_data)
    @wrong_account = OnlineCheckIn::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting households' do
    describe 'Getting list of households' do
      before do
        @account.add_owned_household(DATA[:households][0])
        @account.add_owned_household(DATA[:households][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/households'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/households'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single household' do
      househ = @account.add_owned_household(DATA[:households][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/households/#{househ.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal househ.id
      _(result['attributes']['houseowner']).must_equal househ.houseowner
    end

    it 'SAD: should return error if unknown household requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/households/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get household with wrong authorization' do
      househ = @account.add_owned_household(DATA[:households][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/households/#{househ.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_household(DATA[:households][0])
      @account.add_owned_household(DATA[:households][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/households/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Households' do
    before do
      @househ_data = DATA[:households][0]
    end

    it 'HAPPY: should be able to create new households' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/households', @househ_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      househ = OnlineCheckIn::Household.first

      _(created['id']).must_equal househ.id
      _(created['houseowner']).must_equal @househ_data['houseowner']
    end

    it 'SAD: should not create new household without authorization' do
      post 'api/v1/households', @househ_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create household with mass assignment' do
      bad_data = @househ_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/households', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
