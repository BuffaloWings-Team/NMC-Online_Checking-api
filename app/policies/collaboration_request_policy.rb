# frozen_string_literal: true

module OnlineCheckIn
  # Policy to determine if an account can view a particular household
  class CollaborationRequestPolicy
    def initialize(household, requestor_account, target_account)
      @household = household
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = HouseholdPolicy.new(requestor_account, household)
      @target = HouseholdPolicy.new(target_account, household)
    end

    def can_invite?
      @requestor.can_add_collaborators? && @target.can_collaborate?
    end

    def can_remove?
      @requestor.can_remove_collaborators? && target_is_collaborator?
    end

    private

    def target_is_collaborator?
      @household.collaborators.include?(@target_account)
    end
  end
end
