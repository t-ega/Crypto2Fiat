module Users
  class Creator
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.create(email: email, password: password)
      return :error, user.errors.full_messages if user.errors.present?

      #   TODO: Ensure that a verification link is sent to the user afer sign up
      #   Tokens::Creator.new(user: user)

      [:ok, user]
    end

    pri
  end
end
