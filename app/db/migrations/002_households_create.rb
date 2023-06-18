# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:households) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :houseowner, null: false
      Integer :floorNo, null: false
      Integer :roomNo, null: false
      Float :ping, null: false
      String :email, null: false
      String :phonenumber, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
