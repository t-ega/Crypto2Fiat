module Transactions
  class StatusManager
    attr_reader :transaction_id, :transaction

    def initialize(transaction_id)
      @transaction_id = transaction_id
    end

    def call
      @transaction = Transaction.find_by(public_id: transaction_id)
      return :error, "Transaction not found" if transaction.blank?

      current_state = transaction.aasm.current_state

      case current_state
      when Transaction::STATE_DEPOSIT_INITIATED
        fetch_deposit_status
      when Transaction::STATE_DEPOSIT_CONFIRMED
        fetch_payout_status
      end

      [:ok, transaction]
    end

    def fetch_deposit_status
      status, result =
        Quidax::Deposits.new.fetch_deposits(transaction.from_currency)
      return :error, result if status != :ok

      result.each do |deposit|
        payment_address = deposit["payment_address"]["address"]
        next if payment_address != transaction.payment_address

        deposit_created_at = DateTime.parse(deposit["created_at"])
        transaction_created_at = transaction.created_at

        valid_transaction_range =
          transaction_created_at + Transaction::CONFIRMABLE_PERIOD

        in_valid_deposit_range =
          deposit_created_at.between?(
            transaction_created_at,
            valid_transaction_range
          )

        return if !in_valid_deposit_range

        # Since this desposit is within the transaction
        # timeline (e.g 20mins), it would be safe to **assume** that this deposit belongs to that transaction
        if transaction.from_amount == deposit["amount"]
          transaction.confirm_deposit!
          enque_payout
          transaction.reload
          return
        end
      end
    end

    def fetch_payout_status
    end

    def enqueue_payout
    end
  end
end
