module Kora
  module Payouts
    class SinglePayout < BaseClient
      attr_reader :bank_code,
                  :bank_account,
                  :reference,
                  :receipient_email,
                  :amount

      def initialize(
        bank_code:,
        bank_account:,
        amount:,
        reference:,
        receipient_email:
      )
        @bank_code = bank_code
        @bank_account = bank_account
        @amount = amount
        @reference = reference
        @receipient_email = receipient_email
        super
      end

      def call
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
        return :ok, res[:data] if res[:data]
        [:error, res[:error]]
      rescue Faraday::Error => e
        [:error, e]
      end
    end
  end
end
