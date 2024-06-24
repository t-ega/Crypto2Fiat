module API
  module V1
    class TransactionsController < Grape::API
      namespace :transactions do
        desc "Get the all of a user's transactions"

        params do
          optional :page, type: Integer
          optional :count,
                   type: Integer,
                   coerce_with: ->(count) { [count, 50].min },
                   desc: "The amount of items to be returned. MaX 50"
        end

        get do
          authenticate_user!

          email = current_user&.email

          result = Transactions::Fetcher.new(email: email).call
          render_success(data: result)
        end
      end
    end
  end
end
