# frozen_string_literal: true

module OnlineCheckIn
  # Policy to determine if account can view a household
  class HouseholdPolicy
    # Scope of household policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_households(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |house|
            includes_collaborator?(house, @current_account)
          end
        end
      end

      private

      def all_households(account)
        account.owned_households + account.collaborations
      end

      def includes_collaborator?(household, account)
        household.collaborators.include? account
      end
    end
  end
end
