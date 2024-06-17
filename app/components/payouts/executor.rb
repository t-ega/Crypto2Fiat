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
      transaction.update!(to_amount: result)
      transaction.reload
      #   Initiate the payout
    rescue ActiveRecord::RecordInvalid => invalid
      [:error, invalid.record.errors.full_messages]
    end
  end
end
