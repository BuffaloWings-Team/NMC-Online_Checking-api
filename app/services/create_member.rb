# frozen_string_literal: true

module OnlineCheckIn
  # Add a collaborator to another owner's existing household
  class CreateMember
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more documents'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a document with those attributes'
      end
    end

    def self.call(account:, household:, member_data:)
      policy = HouseholdPolicy.new(account, household)
      raise ForbiddenError unless policy.can_add_members?

      add_member(household, member_data)
    end

    def self.add_member(household, member_data)
      household.add_member(member_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
