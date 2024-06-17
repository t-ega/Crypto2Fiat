module Kora
  module Payouts
    class VerifyPayout < BaseClient
      def initialize
        super
      end

      def call(reference)
        url = "#{Endpoints::TRANSACTION}/#{reference}"
        res = self.get_request(url)

        return :ok, res[:data] if res[:data]
        [:error, res[:error]]
      rescue Faraday::Error => e
        [:error, e]
      end
    end
  end
end
