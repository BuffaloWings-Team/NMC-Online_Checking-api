# frozen_string_literal: true

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
      house_data = HOUSEHOLD_INFO.find { |household| household['house# rubocop:disable Style/HashSyntaxowner'] == household_owner }
      OnlineCheckIn::CreateHouseholdForOwner.call(
        owner_id: account.id, household_data: house_data
      )
    end
  end
end

def create_members
  member_info_each = MEMBER_INFO.each
  households_cycle = OnlineCheckIn::Household.all.cycle
  loop do
    member_info = member_info_each.next
    household = households_cycle.next
    OnlineCheckIn::CreateMemberForHousehold.call(
      household_id: household.id, member_data: member_info
    )
  end
end

def add_collaborators
  contrib_info = CONTRIB_INFO
  contrib_info.each do |contrib|
    household = OnlineCheckIn::Household.first(houseowner: contrib['household_owner'])
    contrib['collaborator_email'].each do |email|
      OnlineCheckIn::AddCollaboratorToHousehold.call(
        email:, household_id: household.id
      )
    end
  end
end
