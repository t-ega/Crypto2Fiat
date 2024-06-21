module Payouts
  class Updater
    attr_reader :transaction_id, :status

    # This just manages the external state of the payout status e.g to deposit_initiated, cancelled
    def initialize(transaction_id:, status:)
      @transaction_id = transaction_id
      @status = status.to_sym
    end

    def call
      transaction = Transaction.find_by(public_id: transaction_id)
      return :error, "Transaction not found" if transaction.blank?

      transaction.aasm.fire!(status) if transaction.aasm.may_fire_event?(status)

      transaction.reload

      [:ok, transaction]
    end
  end
end
