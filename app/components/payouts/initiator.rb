module Payouts
  class Initiator
    attr_reader :transaction_id

    # This just updates the payout status to deposit_initiated
    def initialize(transaction_id)
      @transaction_id = transaction_id
    end

    def call
      transaction = Transaction.find_by(public_id: transaction_id)
      return :error, "Transaction not found" if transaction.blank?

      if transaction.aasm.may_fire_event?(:initiate_deposit)
        transaction.initiate_deposit!
      end

      [:ok, transaction]
    end
  end
end
