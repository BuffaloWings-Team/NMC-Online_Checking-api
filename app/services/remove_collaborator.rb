# frozen_string_literal: true

module OnlineCheckIn
  # Add a collaborator to another owner's existing household
  class RemoveCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, collab_email:, household_id:)
      household = Household.first(id: household_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(
        household, auth[:account], collaborator, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      household.remove_collaborator(collaborator)
      collaborator
    end
  end
end
