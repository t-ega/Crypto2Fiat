module API
  module V1
    class BaseApi < Grape::API
      version "v1"
      include ResponseHelpers

      def authenticate_user!
        render_error(message: Message.unauthorized, code: 401) if !current_user

        current_user
      end

      private

      def current_user
        @current_user ||=
          AuthenticationToken.find_user_from_token(authorization_token)
      end

      def authorization_token
        token = headers["authorization"]
        return if token.blank?

        token = token.split(" ")[1]
      end
    end
  end
end
