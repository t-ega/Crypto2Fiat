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
          requires :currency, values: %w[eth btc usdt]
          optional :network
        end

        get :wallet_address do
          currency = params[:currency]
          _, result = Wallets::Fetcher.new(currency).call

          return render_success(data: result) if result.is_a?(WalletAddress)
          render_success(message: result, data: [])
        end
      end
    end
  end
end
