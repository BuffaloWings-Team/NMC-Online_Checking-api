# frozen_string_literal: true

require 'json'
require 'sequel'

module OnlineCheckIn
  # Models a household
  class Household < Sequel::Model
    one_to_many :documents
    plugin :association_dependencies, documents: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'household',
            attributes: {
              id: id,
              owner: owner,
              floorNo: floorNo,
              contact: contact
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
