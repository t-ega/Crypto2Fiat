module Payouts
  class Updater
    attr_reader :transaction_id, :event
    ALLOWED_EVENTS_FOR_UPDATE = %i[initiate_deposit cancel]

    # This just manages the external state of the payout status e.g to deposit_initiated, cancelled
    def initialize(transaction_id:, event:)
      @transaction_id = transaction_id
      @event = event.to_sym
    end

    def call
      transaction = Transaction.find_by(public_id: transaction_id)
      return :error, "Transaction not found" if transaction.blank?

      if !Payouts::Updater::ALLOWED_EVENTS_FOR_UPDATE.include?(event)
        return :error, "Event not permitted"
      end

      return :error, "Invalid event" if !transaction.aasm.may_fire_event?(event)

      transaction.aasm.fire!(event)

      transaction.reload

      [:ok, transaction]
    end
  end
end
