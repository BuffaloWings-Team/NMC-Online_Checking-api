# frozen_string_literal: true

# Policy to determine if account can view a household
class MemberPolicy
  def initialize(account, member)
    @account = account
    @member = member
  end

  def can_view?
    account_owns_household? || account_collaborates_on_household?
  end

  def can_edit?
    account_owns_household? || account_collaborates_on_household?
  end

  def can_delete?
    account_owns_household? || account_collaborates_on_household?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_household?
    @member.household.owner == @account
  end

  def account_collaborates_on_household?
    @member.household.collaborators.include?(@account)
  end
end
