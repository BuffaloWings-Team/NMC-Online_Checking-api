# frozen_string_literal: true

# Policy to determine if account can view a project
class MemberPolicy
  def initialize(account, member, auth_scope = nil)
    @account = account
    @member = member
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_household? || account_collaborates_on_household?)
  end

  def can_edit?
    can_write? && (account_owns_household? || account_collaborates_on_household?)
  end

  def can_delete?
    can_write? && (account_owns_household? || account_collaborates_on_household?)
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('members') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('members') : false
  end

  def account_owns_household?
    @member.household.owner == @account
  end

  def account_collaborates_on_household?
    @member.household.collaborators.include?(@account)
  end
end
