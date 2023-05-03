# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaboratorToHousehold service' do
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
    OnlineCheckIn::AddCollaboratorToHousehold.call(
      email: @collaborator.email,
      household_id: @household.id
    )

    _(@collaborator.households.count).must_equal 1
    _(@collaborator.households.first).must_equal @household
  end

  it 'BAD: should not add owner as a collaborator' do
    _(proc {
      OnlineCheckIn::AddCollaboratorToHousehold.call(
        email: @owner.email,
        household_id: @household.id
      )
    }).must_raise OnlineCheckIn::AddCollaboratorToHousehold::OwnerNotCollaboratorError
  end
end
