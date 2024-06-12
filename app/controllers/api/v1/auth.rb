module API
  module V1
    class Auth < Grape::API
      desc "Login a user based on email and password"

      params do
        requires :email, type: String, desc: "User email"
        requires :password, type: String, desc: "User password"
      end

      post :login do
        email = params[:email]
        password = params[:password]

        status, result =
          Session::Creator.new(email: email, password: password).call

        render_error(message: result, code: 422) if status != :ok

        render_success(data: result)
      end

      desc "Create a user"

      params do
        requires :email, type: String, desc: "User email"
        requires :password, type: String, desc: "User password"
      end

      post :signup do
        email = params[:email]
        password = params[:password]

        status, result =
          Users::Creator.new(email: email, password: password).call

        render_error(errors: result, code: 422) if status != :ok

        status, result =
          Session::Creator.new(email: email, password: password).call
        render_error(errors: result, code: 422) if status != :ok

        render_success(data: result)
      end

      desc "Verify a user email is correct"

      params do
        requires :token,
                 type: String,
                 desc:
                   "The unique token that was sent to the user in the verify email"
      end

      post :verify do
        token = params[:token]

        status, result = Users::Verifier.new(token: token).call
        return render_error(errors: result) if status != :ok

        render_success(message: "User verified", data: [])
      end

      post :logout do
      end
    end
  end
end
