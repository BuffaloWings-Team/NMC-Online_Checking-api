# frozen_string_literal: true

require_relative './app'

# rubocop:disable Metrics/BlockLength
module OnlineCheckIn
  # Web controller for OnlineCheckIn API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('households') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @househ_route = "#{@api_root}/households"
      routing.on String do |househ_id|
        @req_household = Household.first(id: househ_id)

        # GET api/v1/households/[house_id]/members
        routing.get do
          household = GetHouseholdQuery.call(
            account: @auth_account, household: @req_household
          )

          { data: household }.to_json
        rescue GetHouseholdQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetHouseholdQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND HOUSEHOLD ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('members') do
          # POST api/v1/households/[househ_id]/members
          routing.post do
            new_member = CreateMember.call(
              account: @auth_account,
              household: @req_household,
              member_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@member_route}/#{new_member.id}"
            { message: 'Member saved', data: new_member }.to_json
          rescue CreateMember::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateMember::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create member: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('collaborators') do
          # PUT api/v1/households/[househ_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              account: @auth_account,
              household: @req_household,
              collab_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/households/[househ_id]/collaborators
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              req_username: @auth_account.username,
              collab_email: req_data['email'],
              household_id: househ_id
            )

            { message: "#{collaborator.username} removed from household",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/households
        routing.get do
          households = HouseholdPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: households)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any households' }.to_json
        end

        # POST api/v1/households
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_househ = @auth_account.add_owned_household(new_data)

          response.status = 201
          response['Location'] = "#{@househ_route}/#{new_househ.id}"
          { message: 'Household saved', data: new_househ }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
# rubocop:enable Metrics/BlockLength
