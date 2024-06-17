class ExecutePayoutJob < ApplicationJob
  attr_reader :transaction_id

  def initialize(transaction_id)
    @transaction_id = transaction_id
  end

  def perform
    status, result = Payouts::Executor.new(transaction_id).call
    if status != :ok
      Rails.logger.error(
        "Could not execute payout for transaction with id:#{transaction_id}. Errors: #{result}"
      )
      return
    end

    Rails.logger.info(
      "Successfully executed payout for transaction with id: #{transaction_id}. Results: #{result}"
    )
  end
end
