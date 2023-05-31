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

    def self.call(req_username:, collab_email:, household_id:)
      account = Account.first(username: req_username)
      household = Household.first(id: household_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(household, account, collaborator)
      raise ForbiddenError unless policy.can_remove?

      household.remove_collaborator(collaborator)
      collaborator
    end
  end
end
