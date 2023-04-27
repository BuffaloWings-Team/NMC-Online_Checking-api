# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:members].delete
  app.DB[:households].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:members] = YAML.safe_load File.read('app/db/seeds/member_seeds.yml')
DATA[:households] = YAML.safe_load File.read('app/db/seeds/household_seeds.yml')
