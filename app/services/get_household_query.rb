# frozen_string_literal: true

module OnlineCheckIn
  # Add a collaborator to another owner's existing household
  class GetHouseholdQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that household'
      end
    end

    # Error for cannot find a household
    class NotFoundError < StandardError
      def message
        'We could not find that household'
      end
    end

    def self.call(auth:, household:)
      raise NotFoundError unless household

      policy = HouseholdPolicy.new(auth[:account], household, auth[:scope])
      raise ForbiddenError unless policy.can_view?

      household.full_details.merge(policies: policy.summary)
    end
  end
end
