require "rails_helper"

RSpec.describe Payouts::Creator do
  let(:payment_address) { "123" }
  let(:wallet) { create(:wallet_address) }

  let (:wallet_fetcher) {
    instance_double(Wallets::Fetcher, call: [:ok, wallet])
  }

  before { allow(Wallets::Fetcher).to receive(:new).and_return(wallet_fetcher) }

  describe "when called" do
    it "should create a payout successfully" do
      account_details = { code: "000", account: "00000000" }
      crypto_amount_to_send = 1

      status, result =
        Payouts::Creator.new(
          account_details: account_details,
          from_amount: crypto_amount_to_send,
          from_currency: wallet.currency,
          receipient_email: "email@example.com"
        ).call

      wallet.reload

      expect(status).to eq(:ok)
      expect(wallet.in_use).to eq(true)
      expect(result.public_id).to be_present
      expect(result.status).to eq("initiated")
      expect(result.from_amount).to eq(crypto_amount_to_send)
      expect(result.account_details.symbolize_keys).to eq(account_details)
    end

    it "should not create a payout if there are no unlocked wallets" do
      wallet = create(:wallet_address)

      wallet_fetcher = instance_double(Wallets::Fetcher, call: [:ok, wallet]) # Wallet is originally not in use

      # Implementing a scenairo where a wallet address was fetched immediately
      #  before it was locked for use by another process
      wallet.lock_for_deposit!

      # Now the wallet fetcher would return a wallet that was previous unlocked but now its locked
      allow(Wallets::Fetcher).to receive(:new).and_return(wallet_fetcher)

      account_details = { code: "000", account: "00000000" }
      crypto_amount_to_send = 1

      expect {
        status, result =
          Payouts::Creator.new(
            account_details: account_details,
            from_amount: crypto_amount_to_send,
            from_currency: wallet.currency,
            receipient_email: "email@example.com"
          ).call

        expect(status).to eq(:error)
        expect(result).to eq("Wallet address is already in use!")
      }.not_to change { Transaction.count }
    end
  end
end
