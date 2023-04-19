# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:households].each do |household_data|
      OnlineCheckIn::Household.create(household_data)
    end
  end

  it 'HAPPY: should be able to get list of all documents' do
    house = OnlineCheckIn::Household.first
    DATA[:documents].each do |doc|
      house.add_document(doc)
    end

    get "api/v1/households/#{house.id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single document' do
    doc_data = DATA[:documents][1]
    house = OnlineCheckIn::Household.first
    doc = house.add_document(doc_data).save

    get "/api/v1/households/#{house.id}/documents/#{doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal doc.id
    _(result['data']['attributes']['filename']).must_equal doc_data['filename']
  end

  it 'SAD: should return error if unknown document requested' do
    house = OnlineCheckIn::Household.first
    get "/api/v1/households/#{house.id}/documents/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Documents' do
    before do
      @house = OnlineCheckIn::Household.first
      @doc_data = DATA[:documents][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new documents' do
      # house = OnlineCheckIn::Household.first
      # doc_data = DATA[:documents][1]

      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/households/#{house.id}/documents",
           @doc_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      doc = OnlineCheckIn::Document.first

      _(created['id']).must_equal doc.id
      _(created['filename']).must_equal @doc_data['filename']
      _(created['description']).must_equal @doc_data['description']
    end

    it 'SECURITY: should not create documents with mass assignment' do
      bad_data = @doc_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/households/#{@house.id}/documents",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
