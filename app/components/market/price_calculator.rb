module Market
  class PriceCalculator
    VOLUME_TO_SEND = "send"
    VOLUME_TO_RECIEVE = "receive"
    PRICE_MARKUP = 0.005.freeze
    MINIMUM_FIAT_AMOUNT = 500.freeze

    attr_reader :currency_pair, :vol, :quote_type

    # Needs the currency pair to which it should calculate the price for
    # If no quote type is specified it is assumed the vol is for the base currency(e.g USDT)
    def initialize(currency_pair:, vol:, quote_type: VOLUME_TO_SEND)
      @currency_pair = currency_pair
      @vol = vol.to_f
      @quote_type = quote_type
    end

    def call
      # Ensure the amount to receive(FIAT) is not lower than the minimum amount
      if quote_type == VOLUME_TO_RECIEVE && vol < MINIMUM_FIAT_AMOUNT
        return :error, "Amount to receive is too small"
      end

      status, result = Market::Ticker.new(currency_pair).call
      return :error, result if status != :ok

      estimated_price =
        if quote_type == VOLUME_TO_RECIEVE
          estimate_price_to_send(result)
        else
          estimate_price_to_receive(result)
        end

      markup_price = apply_markup(estimated_price)
      [
        :ok,
        markup_price,
        extra: {
          currency_pair: currency_pair,
          base_amount: result,
          amount_to_recieve: markup_price,
          service_charge: PRICE_MARKUP
        }
      ]
    end

    def apply_markup(price)
      markup_price = price - (price * PRICE_MARKUP)
      markup_price.round(BigDecimal::ROUND_DOWN)
    end

    def estimate_price_to_receive(currency_price)
      vol * currency_price
    end

    def estimate_price_to_send(currency_price)
      vol / currency_price
    end
  end
end
