# frozen_string_literal: true

require 'roda'
require 'json'

module OnlineCheckIn
  # Web controller for OnlineCheckIn API
  class Api < Roda
    plugin :halt
    plugin :multi_route

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CredenceAPI up at /api/v1' }.to_json
      end


      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
