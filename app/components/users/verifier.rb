module Users
  class Verifier
    def initialize(token:)
      @token = token
    end

    def call
      user = AuthenticationToken.find_user_from_token(@token)
      return :error, "No user found" if user.blank?

      return :error, "Unable to verify user" if !user.update(verified: true)

      # revoke the token
      AuthenticationToken.revoke_token(token)
      [:ok]
    end
  end
end
