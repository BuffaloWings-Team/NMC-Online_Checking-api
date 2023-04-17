# frozen_string_literal: true

require 'json'
require 'sequel'

module OnlineCheckIn
  # Models a secret document
  class Document < Sequel::Model
    many_to_one :household

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'document',
            attributes: {
              id: id,
              filename: filename,
              relative_path: relative_path,
              description: description,
              content: content
            }
          },
          included: {
            household: household
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
