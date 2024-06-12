module Tokens
  TOKEN_AUTHENTICATION = ""
  #  WIP 🚧
  class Creator
    def initialize(user:)
      @user = user
    end

    def call
      token =
        AuthenticationToken.create(
          user: @user,
          token: generate_token,
          expires_at: 6.hours.from_now
        )

      [:error, token.errors.full_messages] if token.errors.present?

      [:ok, token]
    end

    private

    def generate_token
      SecureRandom.hex(13)
    end
  end
end
