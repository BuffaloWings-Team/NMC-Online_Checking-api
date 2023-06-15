# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Member Handling' do
  before do
    wipe_database

    DATA[:households].each do |household_data|
      OnlineCheckIn::Household.create(household_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    member_data = DATA[:members][1]
    house = OnlineCheckIn::Household.first
    new_member = house.add_member(member_data)

    member = OnlineCheckIn::Member.find(id: new_member.id)
    _(member.firstname).must_equal member_data['firstname']
    _(member.lastname).must_equal member_data['lastname']
    _(member.dob).must_equal member_data['dob']
  end

  it 'SECURITY: should not use deterministic integers' do
    member_data = DATA[:members][1]
    house = OnlineCheckIn::Household.first
    new_member = house.add_member(member_data)

    _(new_member.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    member_data = DATA[:members][1]
    house = OnlineCheckIn::Household.first
    new_member = house.add_member(member_data)
    stored_member = app.DB[:members].first

    _(stored_member[:dob_secure]).wont_equal new_member.dob
  end
end
