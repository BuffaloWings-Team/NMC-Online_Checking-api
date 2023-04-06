# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Online_Checking
    STORE_DIR = 'app/db/store'

    # Holds a full secret document
    class Document
        # Create a new document by passing in hash of attributes
        def initialize(new_document)
            @id = new_document['id'] || new_id
            @filename = new_document['filename']
            @description = new_document['description']
            @content = new document['content']
        end

        attr_reader :id, :filename, :description, :content

        def to_json(options = {})
            JSON(
                {
                    type: 'document',
                    id: @id,
                    filename: @filename,
                    description: @description,
                    content: @content
                },
                options
            )
        end

        # File store must be setup once when application runs
        def self.setup
            Dir.mkdir(Online_Checking::STORE_DIR) unless Dir.exist? Online_Checking::STORE_DIR
        end

        # Stores document in file store
        def save
            File.write("#{Online_Checking::STORE_DIR}/#{id}.txt", to_json)
        end

        # Query method to find one document
        def self.find(find_id)
            document_file = File.read("#{Online_Checking::STORE_DIR}/#{find_id}.txt")
            Document.new JSON.parse(document_file)
        end
        
        # Query method to retrieve index of all documents
        def self.all
            Dir.glob("#{Online_Checking:STORE_DIR}/*.text").map do |file|
                file.match(%r{#{Regexp.quote(Online_Checking::STORE_DIR)}/(.*)\.text})[1]
            end
        end

        private

        def new_id
            timestamp = Time.now.to_f.to_json
            Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
        end
    end
end