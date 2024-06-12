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
      [:ok, low]
    end
  end
end
