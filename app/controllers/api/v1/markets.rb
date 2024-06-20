module API
  module V1
    class Markets < Grape::API
      namespace :markets do
        desc "Fetch all the supported currencies"

        get "currencylist" do
          currencies = Market::CurrencyLister.call
          render_success(data: currencies)
        end

        desc "Fetch the current price of a currency"

        params do
          optional :quote_type,
                   type: String,
                   default: "send",
                   values: %w[receive send],
                   desc:
                     "The type of quotation you are making. If the vol is what you wish to receive in the 
                     quote currency then set quote_type to receive.
                      Otherwise it is set as the vol you wish to send."
          requires :currency,
                   type: String,
                   values: %w[ethngn btcngn usdtngn],
                   desc:
                     "The currency pair that you need the price. Must be one of 'ethngn, btcngn, usdtngn'"
          requires :vol, type: BigDecimal
        end

        get :quotation do
          currency = params[:currency]
          vol = params[:vol]
          quote_type = params[:quote_type]

          status, result, extra =
            Market::PriceCalculator.new(
              currency_pair: currency,
              vol: vol,
              quote_type: quote_type
            ).call

          render_error(errors: result, code: 400) if status != :ok

          render_success(data: extra)
        end
      end
    end
  end
end
