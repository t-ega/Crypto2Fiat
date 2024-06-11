module Session
  TOKEN_EXPIRATION_TIME = 6.hours.from_now

  class Creator
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.find_by_email(@email)
      return :error, "Invalid email or password" if user.blank?

      if !(user.present? && user.authenticate(@password))
        return :error, "Invalid email or password"
      end

      token =
        AuthenticationToken.create(
          user: user,
          token: generate_token,
          expires_at: TOKEN_EXPIRATION_TIME
        )

      [:ok, token]
    end

    private

    def generate_token
      SecureRandom.hex(13)
    end
  end
end
