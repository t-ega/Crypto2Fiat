module Kora
  module Payouts
    class VerifyPayout < BaseClient
      attr_reader :reference

      def initialize(reference)
        @reference = reference
        super
      end

      def call
        url = "#{Endpoints}/#{reference}"
        res = self.get_request(url)

        return :ok, res[:data] if res[:data]
        [:error, res[:error]]
      rescue Faraday::Error => e
        [:error, e]
      end
    end
  end
end
