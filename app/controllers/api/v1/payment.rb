module API
  module V1
    class Payment < Grape::API
      namespace :payment do
        route_param :id, type: String do
          desc "Update the status of the payout to deposit initiated"

          post "mark-paid" do
            transaction_id = params[:id]

            status, result = Payouts::Initiator.new(transaction_id).call

            render_error(errors: result, code: 400) if status != :ok
            status 200
            render_success(data: result)
          end
        end
      end
    end
  end
end
