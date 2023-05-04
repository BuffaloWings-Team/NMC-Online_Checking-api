# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

# rubocop:disable Style/HashSyntax

module OnlineCheckIn
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_households, class: :'OnlineCheckIn::Household', key: :owner_id

    many_to_many :collaborations,
                 class: :'OnlineCheckIn::Household',
                 join_table: :accounts_households,
                 left_key: :collaborator_id, right_key: :household_id

    plugin :association_dependencies,
           owned_households: :destroy,
           collaborations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def households
      owned_households + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = OnlineCheckIn::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id: id,
          attributes: {
            username: username,
            email: email
          }
        }, options
      )
    end
  end
end
# rubocop:enable Style/HashSyntax
