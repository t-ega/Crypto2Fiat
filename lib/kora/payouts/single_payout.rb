module Kora
  module Payouts
    class SinglePayout < BaseClient
      def initialize
        super
      end

      def call(
        bank_code:,
        bank_account:,
        amount:,
        reference:,
        receipient_email:
      )
        payload = {
          reference: reference,
          destination: {
            type: "bank_account",
            amount: amount,
            currency: "NGN",
            narration: "Transfer Payment to #{receipient_email}",
            bank_account: {
              bank: bank_code,
              account: bank_account
            },
            customer: {
              email: receipient_email
            }
          }
        }

        res = self.post_request(Endpoints::DISBURE, payload)

        if !res[:status]
          return :error, { data: res[:data], message: res[:message] }
        end
        [:ok, res[:data]]
      rescue Faraday::Error => e
        Rails.logger.error("An error occurred. Error: #{e}")
        [:error, "An error occurred"]
      end
    end
  end
end
