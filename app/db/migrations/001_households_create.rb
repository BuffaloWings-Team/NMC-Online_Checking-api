# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:households) do
      primary_key :id

      String :owner, unique: true, null: false
      String :floorNo, unique: true
      String :contact

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
