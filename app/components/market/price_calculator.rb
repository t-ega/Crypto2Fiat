module Market
  class PriceCalculator
    VOLUME_TO_SEND = "send"
    VOLUME_TO_RECIEVE = "receive"
    PRICE_MARKUP = 0.009.freeze
    MINIMUM_FIAT_AMOUNT = 500.freeze

    attr_reader :currency_pair, :vol, :quote_type

    # Needs the currency pair to which it should calculate the price for
    # If no quote type is specified it is assumed the vol is for the base currency (e.g., USDT)
    def initialize(currency_pair:, vol:, quote_type: VOLUME_TO_SEND)
      @currency_pair = currency_pair
      @vol = vol.to_d
      @quote_type = quote_type
    end

    def call
      status, result = Market::Ticker.new(currency_pair).call
      return :error, result if status != :ok

      status, estimate, markup_price =
        if quote_type == VOLUME_TO_RECIEVE
          estimate = estimate_price_to_send(result)
          [:ok, estimate, apply_markup(estimate, reverse: true)] # Remove markup for reverse calculation
        else
          estimate = estimate_price_to_receive(result)
          markup = apply_markup(estimate, fiat: true)
          # Ensure the amount to receive (FIAT) is not lower than the minimum amount
          if markup < MINIMUM_FIAT_AMOUNT
            return :error, "Amount to receive is too small"
          end

          [:ok, estimate, markup]
        end

      return :error, markup_price if status != :ok

      [
        :ok,
        markup_price,
        {
          currency_pair: currency_pair,
          market_price: result,
          amount_to_receive: markup_price,
          service_charge: (estimate * PRICE_MARKUP).round
        }
      ]
    end

    def self.usdt_equivalent(currency:, vol:)
      return :ok, vol if currency == "usdt"

      currency_pair = "#{currency}usdt"
      status, result = Market::Ticker.new(currency_pair).call
      return :error, result if status != :ok

      equivalent = (result * vol)
      [:ok, equivalent]
    end

    def apply_markup(price, fiat: false, reverse: false)
      markup_price =
        (reverse ? price / (1 - PRICE_MARKUP) : price - (price * PRICE_MARKUP))

      return markup_price.round if fiat # We don't send cents
      markup_price.round(5)
    end

    def estimate_price_to_receive(currency_price)
      vol * currency_price
    end

    def estimate_price_to_send(currency_price)
      vol / currency_price
    end
  end
end
