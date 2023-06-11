# frozen_string_literal: true

module OnlineCheckIn
  # Policy to determine if an account can view a particular household
  class CollaborationRequestPolicy
    def initialize(household, requestor_account, target_account, auth_scope = nil)
      @household = household
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = HouseholdPolicy.new(requestor_account, household, auth_scope)
      @target = HouseholdPolicy.new(target_account, household, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_collaborators? && @target.can_collaborate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_collaborators? && target_is_collaborator?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('households') : false
    end

    def target_is_collaborator?
      @household.collaborators.include?(@target_account)
    end
  end
end
