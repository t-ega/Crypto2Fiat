require "rails_helper"

RSpec.describe Payouts::Updater do
  # The Updater class is not responsible for handling logic other than
  # initiating deposit and cancelling them

  describe "when called" do
    let(:transaction) { create(:transaction) }

    it "should update the status of a payout based on an event" do
      event = "initiate_deposit"

      status, result =
        Payouts::Updater.new(
          transaction_id: transaction.public_id,
          event: event
        ).call

      transaction.reload

      expect(status).to eq(:ok)
      expect(transaction.status).to eq("deposit_initiated")

      # sanity check
      expect(result.public_id).to eq(transaction.public_id)
    end

    it "should not update the status if it is invalid" do
      event = "deposit_confrimed"

      status, result =
        Payouts::Updater.new(
          transaction_id: transaction.public_id,
          event: event
        ).call

      transaction_status_was = transaction.status

      transaction.reload
      transaction_status_is = transaction.status

      expect(status).to eq(:error)
      expect(transaction_status_was).to eq(transaction_status_is) # Not change
      expect(result).to eq("Event not permitted")
    end
  end
end
