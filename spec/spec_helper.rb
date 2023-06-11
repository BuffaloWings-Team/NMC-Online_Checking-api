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

def authenticate(account_data)
  OnlineCheckIn::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: OnlineCheckIn::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  members: YAML.load(File.read('app/db/seeds/members_seed.yml')),
  households: YAML.load(File.read('app/db/seeds/households_seed.yml'))
}.freeze
