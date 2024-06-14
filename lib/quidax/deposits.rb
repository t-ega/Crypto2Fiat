module Quidax
  class Deposits < BaseClient
    def initialize
      super
    end

    def fetch_deposits(currency)
      url = "users/me/deposits?currency=#{currency}&state=accepted"
      res = self.get_request(url)

      return :error, res[:error] if res[:error]

      [:ok, res[:data]]
    rescue Faraday::Error => e
      [:error, e]
    end
  end
end
