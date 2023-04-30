# frozen_string_literal: true

module OnlineCheckIn
  # Add a collaborator to another owner's existing household
  class AddCollaboratorToHousehold
    # Error for owner cannot be collaborator
    class OwnerNotCollaboratorError < StandardError
      def message = 'Owner cannot be collaborator of household'
    end

    def self.call(email:, household_id:)
      collaborator = Account.first(email:)
      household = Household.first(id: household_id)
      raise(OwnerNotCollaboratorError) if household.owner.id == collaborator.id

      household.add_collaborator(collaborator)
    end
  end
end
