# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Member Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = OnlineCheckIn::Account.create(@account_data)
    @account.add_owned_household(DATA[:households][0])
    @account.add_owned_household(DATA[:households][1])
    OnlineCheckIn::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single members' do
    it 'HAPPY: should be able to get details of a single member' do
      member_data = DATA[:members][0]
      househ = @account.households.first
      member = househ.add_member(member_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/members/#{member.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal member.id
      _(result['attributes']['first_name']).must_equal member_data['first_name']
      _(result['attributes']['last_name']).must_equal member_data['last_name']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      member_data = DATA[:members][1]
      househ = OnlineCheckIn::Household.first
      member = househ.add_member(member_data)

      get "/api/v1/members/#{member.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      member_data = DATA[:members][0]
      househ = @account.households.first
      member = househ.add_member(member_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/members/#{member.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if member does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/members/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Members' do
    before do
      @househ = OnlineCheckIn::Household.first
      @member_data = DATA[:members][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/households/#{@househ.id}/members", @member_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      member = OnlineCheckIn::Member.first

      _(created['id']).must_equal member.id
      _(created['first_name']).must_equal @member_data['first_name']
      _(created['last_name']).must_equal @member_data['last_name']
      _(created['dob']).must_equal @member_data['dob']

    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/households/#{@househ.id}/members", @member_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/households/#{@househ.id}/members", @member_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @member_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/households/#{@househ.id}/members", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
