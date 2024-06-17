module API
  module V1
    class Payment < Grape::API
      namespace :payment do
        namespace :confrim do
          desc "Get the status of an ongoing payment"
          route_param :id, type: String do
            get do
              transaction_id = params[:id]

              status, result =
                Transactions::StatusManager.new(transaction_id).call

              render_error(errors: result, code: 400) if status != :ok
              render_success(data: result)
            end
          end
        end
      end
    end
  end
end
