# frozen_string_literal: true

require 'roda'
require 'json'

module OnlineCheckIn
  # Web controller for OnlineCheckIn API
  class Api < Roda
    plugin :halt
    plugin :multi_route

<<<<<<< HEAD
module OnlineChecking
  # Web controller for Online Checking System
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Document.setup
    end

    route do |routing| # rubocop:disable Metics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'OnlineCheckingAPI up at /api/v1' }.to_json
=======
    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      routing.root do
        { message: 'OnlineCheckInAPI up at /api/v1' }.to_json
>>>>>>> 5-deployable
      end

      routing.on 'api' do
        routing.on 'v1' do
<<<<<<< HEAD
          routing.on 'documents' do
            # GET api/v1/documents/[id]
            routing.get String do |id|
              # response.status = 200
              Document.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Document not found' }.to_json
            end

            # GET api/v1/documents
            routing.get do
              # response.status = 200
              output = { document_ids: Document.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/documents
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Document.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Document saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save document' }.to_json
              end
            end
          end
=======
          @api_root = 'api/v1'
          routing.multi_route
>>>>>>> 5-deployable
        end
      end
    end
  end
end
