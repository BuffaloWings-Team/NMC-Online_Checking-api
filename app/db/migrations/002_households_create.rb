# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:households) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :houseowner, unique: true, null: false
      String :floorNo, null: false
      String :contact, null: false, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
