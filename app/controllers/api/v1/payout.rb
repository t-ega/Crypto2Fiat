module API
  module V1
    class Payout < Grape::API
      namespace :payouts do
        desc "Get details of all the supported banks"

        get "list_banks" do
          Rails
            .cache
            .fetch("list_banks", expires_in: 3.hours) do
              status, result = Kora::ListBanks.new.call
              render_error(errors: result, code: 400) if status != :ok
              render_success(data: result)
            end
        end

        desc "Verify the details of an account"

        params do
          requires :bank_code, type: String
          requires :account_number,
                   type: String,
                   length: {
                     min: 10,
                     message:
                       "Account number is expected to be atleast 10 characters long"
                   }
        end

        get "resolve_bank" do
          bank_code = params[:bank_code]
          account_number = params[:account_number]

          status, result =
            Kora::ResolveBank.new.call(
              bank_code: bank_code,
              account_number: account_number
            )
          render_error(errors: result, code: 400) if status != :ok
          render_success(data: result)
        end

        route_param :id, type: String do
          desc "Update the status of the payout"

          params do
            requires :status, type: Symbol, values: %i[cancel initiate_deposit]
          end

          post "status" do
            transaction_id = params[:id]
            event = params[:status]

            status, result =
              Payouts::Updater.new(
                transaction_id: transaction_id,
                event: event
              ).call

            render_error(errors: result, code: 400) if status != :ok
            status 200
            render_success(data: result)
          end
        end

        desc "Initiate a Payout to the receipient bank"

        params do
          requires :receipient_email, type: String
          requires :from_currency,
                   type: String,
                   coerce_with: ->(c) { c.downcase },
                   values: WalletAddress::ALLOWED_CURRENCIES_LIST
          requires :from_amount, type: BigDecimal
          requires :bank_details, type: Hash do
            requires :bank_code, type: String
            requires :account_number, type: String
          end

          optional :sender_email, type: String
        end

        post do
          receipient_email = params[:receipient_email]
          from_currency = params[:from_currency]
          from_amount = params[:from_amount]
          bank_details = params[:bank_details]
          sender_email = current_user&.email

          status, result =
            Payouts::Creator.new(
              from_currency: from_currency,
              from_amount: from_amount,
              account_details: bank_details,
              receipient_email: receipient_email,
              sender_email: sender_email
            ).call

          render_error(errors: result, code: 422) if status != :ok
          render_success(data: result.as_json(except: %w[id]))
        end

        desc "Get status of a payout"

        params { requires :public_id, type: String }

        get :status do
          public_id = params[:public_id]
          status, result = Transactions::StatusManager.new(public_id).call
          render_error(message: result, code: 404) if status != :ok
          render_success(data: result.as_json(exclude: %w[id]))
        end
      end
    end
  end
end
