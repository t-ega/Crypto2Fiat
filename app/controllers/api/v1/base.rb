module API
  module V1
    class Base < Grape::API
      version "v1"
      helpers ResponseHelpers

      helpers do
        def authenticate_user!
          if !current_user
            render_error(message: Message.unauthorized, code: 401)
          end

          current_user
        end

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

      rescue_from Grape::Exceptions::ValidationErrors do |e|
        render_error(
          message: Message.validation_error,
          errors: e.full_messages,
          code: 400
        )
      end

      rescue_from :all do |e|
        # TODO: Write errors to a log file or an error monitoring tool like sentry
        Rails.logger.error(e)

        render_error(message: Message.internal_error, code: 500)
      end

      mount Auth
      mount Markets
      mount Payout
    end
  end
end
