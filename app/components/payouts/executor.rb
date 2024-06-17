module Payouts
  class Executor
    attr_reader :transaction_id, :transaction

    def initialize(transaction_id)
      @transaction_id = transaction_id
    end

    def call
      transaction = Transaction.find_by(public_id: transaction_id)
      return :error, "Transaction not found" if transaction.blank?

      if transaction.deposit_confrimed_at.blank?
        return :error, "Transaction has not been confirmed"
      end

      if transaction.payout_confrimed_at.present?
        return :error, "Payout already executed"
      end

      # Calculate the to_amount for the transaction
      status, result =
        Market::PriceCalculator.new(
          currency_pair: transaction.extract_currency_pair,
          vol: transaction.from_amount,
          quote_type: VOLUME_TO_SEND
        )

      return :error, result if status != :ok

      transaction.with_lock do
        transaction.update!(
          to_amount: result,
          payout_reference: generate_reference
        )
        transaction.initiate_payout!

        transaction.reload
      end

      status, result =
        # Initiate the payout
        # We are in test mode, so we have to use the test accounts to simulate a success payout
        Kora::Payouts.new(
          bank_code: "033",
          bank_account: "0000000000",
          amount: transaction.to_amount,
          reference: transaction.payout_reference,
          receipient_email: transaction.receipient_email
        ).call

      if status != :ok
        transaction.fail_transaction!
        return :error, result
      end

      [:ok, result]
    rescue ActiveRecord::RecordInvalid => invalid
      [:error, invalid.record.errors.full_messages]
    end

    def generate_reference
      SecureRandom.uuid
    end
  end
end
