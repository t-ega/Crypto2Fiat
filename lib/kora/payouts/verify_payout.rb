module Kora
  module Payouts
    class VerifyPayout < BaseClient
      def initialize
        super
      end

      def call(reference)
        url = "#{Endpoints::TRANSACTION}/#{reference}"
        res = self.get_request(url)

        return :error, res if !res[:status]
        [:ok, res[:data]]
      rescue Faraday::Error => e
        Rails.logger.error("An error occurred. Error: #{e}")
        [:error, "An error occurred"]
      end
    end
  end
end
