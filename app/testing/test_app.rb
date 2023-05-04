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
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end

        routing.on 'households' do
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

              # POST api/v1/households/[ID]/members
              routing.post do
                new_data = JSON.parse(routing.body.read)
                #house = Household.first(id: house_id)
                #new_member = house.add_member(new_data)
                #raise 'Could not save member' unless new_member
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
