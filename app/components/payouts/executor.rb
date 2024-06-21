module Payouts
  class Executor
    attr_reader :transaction_id, :transaction

    def initialize(transaction_id)
      @transaction_id = transaction_id
    end

    def call
      transaction = Transaction.find_by(public_id: transaction_id)
      return :error, "Transaction not found" if transaction.blank?

      if transaction.deposit_confirmed_at.blank?
        return :error, "Transaction has not been confirmed"
      end

      if transaction.payout_confirmed_at.present?
        return :error, "Payout already executed"
      end

      # Calculate the to_amount for the transaction
      status, result, extra =
        Market::PriceCalculator.new(
          currency_pair: transaction.extract_currency_pair,
          vol: transaction.from_amount,
          quote_type: Market::PriceCalculator::VOLUME_TO_SEND
        ).call

      return :error, result if status != :ok

      transaction.with_lock do
        transaction.update!(
          to_amount: result,
          metadata: extra,
          payout_reference: generate_reference
        )
        transaction.initiate_payout!

        transaction.reload
      end

      status, result =
        # Initiate the payout
        # We are in test mode, so we have to use the test accounts to simulate a success payout
        Kora::Payouts::SinglePayout.new.call(
          bank_code: "033",
          bank_account: "0000000000",
          amount: [transaction.to_amount.to_f, 100_000].min, # Test money, should not finish
          reference: transaction.payout_reference,
          receipient_email: transaction.receipient_email
        )

      if status != :ok
        transaction.mark_transaction_as_failed(reason: result)
        return :error, result
      end

      [:ok, result]
    rescue ActiveRecord::RecordInvalid => invalid
      [:error, invalid.record.errors.full_messages]
    rescue StandardError => e
      Rails.logger.error("An unknown error occurred, #{e.inspect}")
      [:error, "An unknown error occurred"]
    end

    def generate_reference
      SecureRandom.uuid
    end
  end
end
