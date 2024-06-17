module API
  module V1
    class Payout < Grape::API
      namespace :payouts do
        desc "Get details of all the supported banks"

        get :list_banks do
          Rails
            .cache
            .fetch("list_banks", expires_in: 3.hours) do
              status, result = Kora::ListBanks.new.call
              render_error(errors: result, code: 400) if status != :ok
              render_success(data: result)
            end
        end

        desc "Fetch wallet address to initiate a payout"

        params do
          requires :currency, values: WalletAddress::ALLOWED_CURRENCIES_LIST
          optional :network
        end

        get :wallet_address do
          currency = params[:currency]
          _, result = Wallets::Fetcher.new(currency).call

          return render_success(data: result) if result.is_a?(WalletAddress)
          status 202 # This would tell the server that we have accepted and we are generating the address
          render_success(message: result)
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

        params { requires :transaction_id, type: String }

        get :status do
          transaction_id = params[:transaction_id]
          status, result = Transactions::StatusManager.new(transaction_id).call
          render_error(errors: result) if status != :ok
          render_success(data: result.as_json(exclude: %w[id]))
        end
      end
    end
  end
end
