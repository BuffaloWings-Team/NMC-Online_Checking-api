# frozen_string_literal: true

require 'json'
require 'sequel'

module OnlineCheckIn
  # Models a household
  class Attendance < Sequel::Model
    one_to_one :household

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'attendance',
            attributes: {
              id: id,
              status: status,
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end