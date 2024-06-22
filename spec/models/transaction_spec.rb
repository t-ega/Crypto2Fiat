require "rails_helper"

RSpec.describe Transaction, type: :model do
  it { should validate_presence_of(:payment_address) }
  it { should validate_presence_of(:account_details) }
  it { should validate_presence_of(:from_amount) }
  it { should validate_presence_of(:to_currency) }
  it { should validate_presence_of(:receipient_email) }
  it { should validate_presence_of(:public_id) }
  it { should validate_presence_of(:network) }

  describe "methods" do
    it "should return a currency pair using the from and to currency" do
      transaction =
        create(:transaction, from_currency: "EtH", to_currency: "nGn")
      expected_currency_pair = "ethngn"
      expect(transaction.extract_currency_pair).to eq(expected_currency_pair)
    end

    it "should mark a payout as completed" do
      account_details = { code: "000", account: "000000" }
      transaction =
        Transaction.create(
          payment_address: "address",
          account_details: account_details,
          from_amount: 1,
          to_currency: "ngn",
          receipient_email: "email@example.com",
          public_id: "pub_id",
          network: "bep20",
          status: "payout_initiated"
        )

      expect {
        transaction.confirm_payout!
        transaction.reload
        expect(transaction.payout_confirmed_at).to be_present
      }.to change { transaction.status }.from("payout_initiated").to(
        "payout_completed"
      )
    end

    it "should mark a deposit as confirmed" do
      account_details = { code: "000", account: "000000" }
      transaction =
        Transaction.create(
          payment_address: "address",
          account_details: account_details,
          from_amount: 1,
          to_currency: "ngn",
          receipient_email: "email@example.com",
          public_id: "pub_id",
          network: "bep20",
          status: "deposit_initiated"
        )

      expect {
        transaction.confirm_deposit!
        transaction.reload
        expect(transaction.deposit_confirmed_at).to be_present
      }.to change { transaction.status }.from("deposit_initiated").to(
        "deposit_confirmed"
      )
    end

    it "should mark a payout as failed" do
      account_details = { code: "000", account: "000000" }
      transaction =
        Transaction.create(
          payment_address: "address",
          account_details: account_details,
          from_amount: 1,
          to_currency: "ngn",
          receipient_email: "email@example.com",
          public_id: "pub_id",
          network: "bep20",
          status: "payout_initiated"
        )

      failure_reason = "failure"
      expect {
        transaction.mark_transaction_as_failed(reason: failure_reason)
        transaction.reload
        expect(transaction.failed_at).to be_present
        expect(transaction.failure_reason).to eq(failure_reason)
      }.to change { transaction.status }.from("payout_initiated").to("failed")
    end
  end
end
