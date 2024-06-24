module Users
  class Creator
    attr_reader :email, :password

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      existing_user = User.find_by_email(email)
      if existing_user.present?
        return :error, "A user with this email already exists."
      end

      user = User.create(email: email, password: password)
      return :error, user.errors.full_messages if user.errors.present?

      status, token =
        Session::Creator.new(email: email, password: password).call
      return :error, token if status != :ok

      [:ok, { user: user, token: token }]
    end
  end
end
