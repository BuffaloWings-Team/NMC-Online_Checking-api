# frozen_string_literal: true

module OnlineCheckIn
    # Maps Github account details to attributes
    class GithubAccount
      def initialize(gh_account)
        @gh_account = gh_account
      end
  
      def username
        @gh_account['login'] + '@github'
      end
  
      def email
        if @gh_account['email'].nil?
          email = 'null' + '@github.com' # to prevent not getting email error
        else
          @gh_account['email']
        end
      end
    end
  end