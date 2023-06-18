# frozen_string_literal: true

module OnlineCheckIn
  # Policy to determine if an account can view a particular household
  class HouseholdPolicy
    def initialize(account, household, auth_scope = nil)
      @account = account
      @household = household
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_collaborator?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && (account_is_owner? || account_is_collaborator?)
    end

    def can_delete?
      can_write? && account_is_owner?
    end

   def can_leave?
     account_is_collaborator?
   end

    def can_add_members?
      can_write? && (account_is_owner?|| account_is_collaborator?)
    end

    def can_remove_members?
      can_write? && (account_is_owner?|| account_is_collaborator?)
    end

    def can_add_collaborators?
      can_write? && account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def can_collaborate?
      !(account_is_owner? || account_is_collaborator?)
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_members: can_add_members?,
        can_remove_members: can_remove_members?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('household') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('household') : false
    end

    def account_is_owner?
      @household.owner == @account
    end

    def account_is_collaborator?
      @household.collaborators.include?(@account)
    end
  end
end
