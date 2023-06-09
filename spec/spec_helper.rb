# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  OnlineCheckIn::Member.map(&:destroy)
  OnlineCheckIn::Household.map(&:destroy)
  OnlineCheckIn::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = OnlineCheckIn::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  members: YAML.load(File.read('app/db/seeds/members_seed.yml')),
  households: YAML.load(File.read('app/db/seeds/households_seed.yml'))
}.freeze
