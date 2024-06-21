class ExecutePayoutJob < ApplicationJob
  def perform(transaction_id:)
    status, result = Payouts::Executor.new(transaction_id).call

    if status != :ok
      Rails.logger.error(
        "Could not execute payout for transaction with id:#{transaction_id}. Errors: #{result.inspect}"
      )
      return
    end

    Rails.logger.info(
      "Successfully executed payout for transaction with id: #{transaction_id}. Results: #{result.inspect}"
    )
  end
end
