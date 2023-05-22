# frozen_string_literal: true

require 'roda'
require 'json'

module OnlineCheckIn
  # Web controller for OnlineCheckIn API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('households') do |routing|
      @house_route = "#{@api_root}/households"

      routing.on String do |house_id|
        routing.on 'members' do
          @member_route = "#{@api_root}/households/#{house_id}/members"
          # GET api/v1/households/[house_id]/members/[member_id]
          routing.get String do |member_id|
            member = Member.where(household_id: house_id, id: member_id).first
            member ? member.to_json : raise('Member not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/households/[house_id]/members
          routing.get do
            output = { data: Household.first(id: house_id).members }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find members'
          end

          # POST api/v1/households/[member_id]/members
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_member = CreateMemberForHousehold.call(
              household_id: house_id, member_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@member_route}/#{new_member.id}"
            { message: 'member saved', data: new_member }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError
            Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/households/[house_id]
        routing.get do
          house = Household.first(id: house_id)
          house ? house.to_json : raise('Household not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/households
      account = Account.first(username: @auth_account['username'])
      households = account.households
      JSON.pretty_generate(data: households)
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any households' }.to_json
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
    # rubocop:enable Metrics/BlockLength
  end
end