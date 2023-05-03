# frozen_string_literal: true

require 'json'
require 'sequel'

# rubocop:disable Style/HashSyntax

module OnlineCheckIn
  # Models a household
  class Household < Sequel::Model
    many_to_one :owner, class: :'OnlineCheckIn::Account'

    many_to_many :collaborators,
                 class: :'OnlineCheckIn::Account',
                 join_table: :accounts_households,
                 left_key: :household_id, right_key: :collaborator_id

    one_to_many :members

    plugin :association_dependencies,
           members: :destroy,
           collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :houseowner, :floorNo, :contact
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'household',
            attributes: {
              id: id,
              houseowner: houseowner,
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
# rubocop:enable Style/HashSyntax
