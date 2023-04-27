# frozen_string_literal: true

module OnlineCheckIn
  # Service object to create a new household for an owner
  class CreateHouseholdForOwner
    def self.call(owner_id:, household_data:)
      Account.find(id: owner_id)
             .add_owned_household(household_data)
    end
  end
end
