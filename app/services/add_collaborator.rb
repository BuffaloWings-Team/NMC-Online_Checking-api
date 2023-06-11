# frozen_string_literal: true

module OnlineCheckIn
  # Add a collaborator to another owner's existing household
  class AddCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def self.call(auth:, household:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = CollaborationRequestPolicy.new(
        household, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      household.add_collaborator(invitee)
      invitee
    end
  end
end
