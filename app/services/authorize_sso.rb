# frozen_string_literal: true

require 'http'

module OnlineCheckIn
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    def call(access_token)
      print("stop before get_github_account\n")
      github_account = get_github_account(access_token)
      print("github_account is",github_account.to_s,"\n")
      sso_account = find_or_create_sso_account(github_account)
      print("sso_account is",sso_account.to_s,"\n")
      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_response = HTTP.headers(
        user_agent: 'OnlineCheckIn',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV['GITHUB_ACCOUNT_URL'])

      raise unless gh_response.status == 200
      print("gh_response is",gh_response.to_s)
      account = GithubAccount.new(JSON.parse(gh_response))
      print("account ",account.to_s)
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      print("account_data is",account_data.to_s,"\n")
      Account.first(email: account_data[:email]) ||
        Account.create_github_account(account_data)
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: ,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end