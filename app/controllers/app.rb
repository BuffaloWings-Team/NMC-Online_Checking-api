# frozen_string_literal: true

require 'roda'
require 'json'

module OnlineCheckIn
  # Web controller for OnlineCheckIn API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'OnlineCheckInAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'households' do
          @house_route = "#{@api_root}/households"

          routing.on String do |house_id|
            routing.on 'documents' do
              @doc_route = "#{@api_root}/households/#{house_id}/documents"
              # GET api/v1/households/[house_id]/documents/[doc_id]
              routing.get String do |doc_id|
                doc = Document.where(household_id: house_id, id: doc_id).first
                doc ? doc.to_json : raise('Document not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/households/[house_id]/documents
              routing.get do
                output = { data: Household.first(id: house_id).documents }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find documents'
              end

              # POST api/v1/households/[ID]/documents
              routing.post do
                new_data = JSON.parse(routing.body.read)
                house = Household.first(id: house_id)
                new_doc = house.add_document(new_data)
                raise 'Could not save document'

                response.status = 201
                response['Location'] = "#{@doc_route}/#{new_doc.id}"
                { message: 'Document saved', data: new_doc }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/households/[ID]
            routing.get do
              house = Household.first(id: house_id)
              house ? house.to_json : raise('Household not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/households
          routing.get do
            output = { data: Household.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find households' }.to_json
          end

          # POST api/v1/households
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_house = Household.new(new_data)
            raise('Could not save household') unless new_house.save

            response.status = 201
            response['Location'] = "#{@house_route}/#{new_house.id}"
            { message: 'Household saved', data: new_house }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
