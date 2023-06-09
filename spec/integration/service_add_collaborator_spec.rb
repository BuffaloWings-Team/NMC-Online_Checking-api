# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      OnlineCheckIn::Account.create(account_data)
    end

    household_data = DATA[:households].first

    @owner = OnlineCheckIn::Account.all[0]
    @collaborator = OnlineCheckIn::Account.all[1]
    @household = OnlineCheckIn::CreateHouseholdForOwner.call(
      owner_id: @owner.id, household_data:
    )
  end

  it 'HAPPY: should be able to add a collaborator to a household' do
    OnlineCheckIn::AddCollaborator.call(
      account: @owner,
      household_id: @household,
      email: @collaborator.email
    )

    _(@collaborator.households.count).must_equal 1
    _(@collaborator.households.first).must_equal @household
  end

  it 'BAD: should not add owner as a collaborator' do
    _(proc {
      OnlineCheckIn::AddCollaborator.call(
        account: @owner,
        household_id: @household,
        email: @collaborator.email
      )
    }).must_raise OnlineCheckIn::AddCollaborator::ForbiddenError
  end
end
