# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:members) do
      uuid :id, primary_key: true
      foreign_key :household_id, table: :households

      String :firstname, null: false
      String :lastname, null: false
      String :dob_secure, null: false

      DateTime :created_at
      DateTime :updated_at

      unique [:household_id]
    end
  end
end
