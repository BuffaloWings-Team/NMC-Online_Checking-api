# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Household Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all households' do
    OnlineCheckIn::Household.create(DATA[:households][0]).save
    OnlineCheckIn::Household.create(DATA[:households][1]).save

    get 'api/v1/households'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single household' do
    existing_house = DATA[:households][1]
    OnlineCheckIn::Household.create(existing_house).save
    id = OnlineCheckIn::Household.first.id

    get "/api/v1/households/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['owner']).must_equal existing_house['owner']
  end

  it 'SAD: should return error if unknown household requested' do
    get '/api/v1/households/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new households' do
    existing_house = DATA[:households][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/households', existing_house.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    house = OnlineCheckIn::Household.first

    _(created['id']).must_equal house.id
    _(created['owner']).must_equal existing_house['owner']
    _(created['floorNo']).must_equal existing_house['floorNo']
    _(created['contact']).must_equal existing_house['contact']
  end
end
