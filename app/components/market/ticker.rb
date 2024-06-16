module Market
  class Ticker
    attr_reader :currency

    def initialize(currency)
      @currency = currency
    end

    def call
      status, result = Quidax::Markets.new.fetch_ticker(currency)
      return :error, result if status != :ok

      low = result.dig(:ticker, :low)
      # Safe to convert to float because the API already returns to you the number rounded to 2 decimal places
      [:ok, low.to_f]
    end
  end
end
