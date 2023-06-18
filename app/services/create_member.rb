# frozen_string_literal: true

module OnlineCheckIn
  # Add a collaborator to another owner's existing household
  class CreateMember
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more members'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a member with those attributes'
      end
    end

    def self.call(auth:, household:, member_data:)
      policy = HouseholdPolicy.new(auth[:account], household, auth[:scope])
      raise ForbiddenError unless policy.can_add_members?
      household.add_member(member_data)

    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
