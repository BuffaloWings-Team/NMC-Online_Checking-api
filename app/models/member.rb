# frozen_string_literal: true

require 'json'
require 'sequel'

# rubocop:disable Style/HashSyntax

module OnlineCheckIn
  # Models a secret member
  class Member < Sequel::Model
    many_to_one :household

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :firstname, :lastname, :dob

    # # Secure getters and setters
    # def dob
    #   SecureDB.decrypt(dob_secure)
    # end

    # def dob=(plaintext)
    #   self.dob_secure = SecureDB.encrypt(plaintext)
    # end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          type: 'member',
          attributes: {
            id: id,
            firstname: firstname,
            lastname: lastname,
            dob: dob 
          },
          include: {
            household: household
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
# rubocop:enable Style/HashSyntax
