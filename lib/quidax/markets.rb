module Quidax
  class Markets < BaseClient
    def initialize
      super
    end

    def fetch_ticker(currency)
      url = "#{Endpoints::MARKET_TICKER}/#{currency}"
      res = self.get_request(url)

      return :ok, res[:data] if res[:data]
      [:error, res[:error]]
    rescue Faraday::Error => e
      Rails.logger.error("An error occurred. Error: #{e}")
      [:error, "An error occurred"]
    end
  end
end
