# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test OnlineCheckIn Web API' do
  before do
    Dir.glob('app/db/store/*.txt').each { |filename| FileUtils.rm(filename) }
  end

  describe 'Root route' do
    it 'should find the root route' do
      get '/'
      _(last_response.status).must_equal 200
    end
  end
end
