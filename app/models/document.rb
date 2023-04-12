# frozen_string_literal: true

require 'json'
require 'sequel'

module OnlineCheckIn
  # Models a secret document
  class Document < Sequel::Model
    many_to_one :project

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'document',
            attributes: {
              id:,
              filename:,
              relative_path:,
              description:,
              content:
            }
          },
          included: {
            project:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
