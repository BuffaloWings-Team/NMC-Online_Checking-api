# frozen_string_literal: true

require './app/controllers/helpers.rb'
include OnlineCheckIn::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, households, members'
    create_accounts
    create_owned_households
    create_members
    add_collaborators
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_households.yml")
HOUSEHOLD_INFO = YAML.load_file("#{DIR}/households_seed.yml")
MEMBER_INFO = YAML.load_file("#{DIR}/members_seed.yml")
CONTRIB_INFO = YAML.load_file("#{DIR}/households_collaborators.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    OnlineCheckIn::Account.create(account_info)
  end
end

def create_owned_households
  OWNER_INFO.each do |owner|
    account = OnlineCheckIn::Account.first(username: owner['username'])
    owner['household_owner'].each do |household_owner|
      house_data = HOUSEHOLD_INFO.find { |household| household['houseowner'] == household_owner }
      account.add_owned_household(house_data)
    end
  end
end

def create_members
  member_info_each = MEMBER_INFO.each
  households_cycle = OnlineCheckIn::Household.all.cycle
  loop do
    member_info = member_info_each.next
    household = households_cycle.next

    auth_token = AuthToken.create(household.owner)
    auth = scoped_auth(auth_token)

    OnlineCheckIn::CreateMember.call(
      auth: auth, household: household, member_data: member_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    household = OnlineCheckIn::Household.first(houseowner: contrib['household_owner'])

    auth_token = AuthToken.create(household.owner)
    auth = scoped_auth(auth_token)

    contrib['collaborator_email'].each do |email|
      OnlineCheckIn::AddCollaborator.call(
        auth: auth, household: household, collab_email: email
      )
    end
  end
end
