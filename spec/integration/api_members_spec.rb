# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Member Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:households].each do |household_data|
      OnlineCheckIn::Household.create(household_data)
    end
  end

  it 'HAPPY: should be able to get list of all members' do
    house = OnlineCheckIn::Household.first
    DATA[:members].each do |member|
      house.add_member(member)
    end

    get "api/v1/households/#{house.id}/members"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result.count).must_equal 4
    result.each do |member|
      _(member['type']).must_equal 'member'
    end
  end

  it 'HAPPY: should be able to get details of a single member' do
    member_data = DATA[:members][1]
    house = OnlineCheckIn::Household.first
    member = house.add_member(member_data)

    get "/api/v1/households/#{house.id}/members/#{member.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal member.id
    _(result['attributes']['first_name']).must_equal member_data['first_name']
  end

  it 'SAD: should return error if unknown member requested' do
    house = OnlineCheckIn::Household.first
    get "/api/v1/households/#{house.id}/members/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating members' do
    before do
      @house = OnlineCheckIn::Household.first
      @member_data = DATA[:members][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new members' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/households/#{@house.id}/members",
           @member_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      member = OnlineCheckIn::Member.first

      _(created['id']).must_equal member.id
      _(created['first_name']).must_equal @member_data['first_name']
      _(created['dob']).must_equal @member_data['dob']
    end

    it 'SECURITY: should not create members with mass assignment' do
      bad_data = @member_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/households/#{@house.id}/members",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
