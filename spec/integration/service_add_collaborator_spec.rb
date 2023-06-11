# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      OnlineCheckIn::Account.create(account_data)
    end

    household_data = DATA[:households].first

    @owner_data = DATA[:accounts][0]
    @owner = OnlineCheckIn::Account.all[0]
    @collaborator = OnlineCheckIn::Account.all[1]
    @household = @owner.add_owned_household(household_data)
  end

  it 'HAPPY: should be able to add a collaborator to a household' do
    auth = authorization(@owner_data)
    
    OnlineCheckIn::AddCollaborator.call(
      auth: auth,
      household: @household,
      collab_email: @collaborator.email
    )

    _(@collaborator.households.count).must_equal 1
    _(@collaborator.households.first).must_equal @household
  end

  it 'BAD: should not add owner as a collaborator' do
    auth = OnlineCheckIn::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )
    
    _(proc {
      OnlineCheckIn::AddCollaborator.call(
        auth: auth,
        household: @household,
        collab_email: @owner.email
      )
    }).must_raise OnlineCheckIn::AddCollaborator::ForbiddenError
  end
end
