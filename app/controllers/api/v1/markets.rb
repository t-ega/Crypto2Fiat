module API
  module V1
    class Markets < Grape::API
      namespace :markets do
        desc "Fetch all the supported currencies"

        get :supported_currencies do
          currencies = Markets::CurrencyLister.call
          render_success(data: currencies)
        end

        desc "Fetch the current price of a currency"

        params do
          requires :currency,
                   type: String,
                   values: %w[ethngn btcngn usdtngn],
                   desc:
                     "The currency pair that you need the price. Must be one of 'ethngn, btcngn, usdtngn'"
        end

        get :price do
          currency = params[:currency]

          status, result = Market::Ticker.new(currency).call

          render_error(errors: result, code: 400) if status != :ok

          render_success(data: result)
        end
      end
    end
  end
end
