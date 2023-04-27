# frozen_string_literal: true

module OnlineCheckIn
  # Create new configuration for a household
  class CreateMemberForHousehold
    def self.call(household_id:, member_data:)
      Household.first(id: household_id)
               .add_member(member_data)
    end
  end
end
