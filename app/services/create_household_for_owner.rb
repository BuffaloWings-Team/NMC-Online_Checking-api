# frozen_string_literal: true

module OnlineCheckIn
  # Service object to create a new household for an owner
  class CreateHouseholdForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create households'
      end
    end

    def self.call(auth:, household_data:)
      raise ForbiddenError unless auth[:scope].can_write?('households')
      househ = auth[:account].add_owned_household(household_data)
    end
  end
end
