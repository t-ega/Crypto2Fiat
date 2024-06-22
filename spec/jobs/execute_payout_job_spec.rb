RSpec.describe ExecutePayoutJob, type: :job do
  describe "when queued" do
    it "should execute the payout" do
      payout_executor_mock = instance_double(Payouts::Executor, call: [:ok])
      expect(Payouts::Executor).to receive(:new).and_return(
        payout_executor_mock
      )

      ExecutePayoutJob.perform_now(transaction_id: "transaction_id")
    end
  end
end
