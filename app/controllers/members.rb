# frozen_string_literal: true

require_relative './app'

module OnlineCheckIn
  # Web controller for OnlineCheckIn API
  class Api < Roda
    route('members') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @member_route = "#{@api_root}/members"

      # GET api/v1/memberss/[member_id]
      routing.on String do |member_id|
        @req_member = Member.first(id: member_id)

        routing.get do
          member = GetMemberQuery.call(
            auth: @auth, member: @req_member
          )

          { data: member }.to_json
        rescue GetMemberQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetMemberQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Member Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
