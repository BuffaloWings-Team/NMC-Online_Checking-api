# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:documents) do
      uuid: :id, primary_key true
      foreign_key :household_id, table: :households

      String :filename, null: false
      String :relative_path, null: false, default: ''
      String :description_secure
      String :content_secure, null: false, default: ''

      DateTime :created_at
      DateTime :updated_at

      unique [:household_id, :relative_path, :filename]
    end
  end
end
