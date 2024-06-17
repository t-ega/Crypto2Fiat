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

        puts "Payload: #{payload}\n\n"

        res = self.post_request(Endpoints::DISBURE, payload)
        return :ok, res[:data] if res[:data]
        [:error, res[:error]]
      rescue Faraday::Error => e
        [:error, e]
      end
    end
  end
end
