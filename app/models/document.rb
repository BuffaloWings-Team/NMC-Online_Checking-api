# frozen_string_literal: true

require 'json'
require 'sequel'

module OnlineCheckIn
  # Models a secret document
  class Document < Sequel::Model
    many_to_one :household

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :filename, :relative_path, :description, :content

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end
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
